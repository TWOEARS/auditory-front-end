classdef modulationProc < Processor
    
    properties
        modCfHz         % Modulation filters center frequencies
        filterType      % 'fft' vs. 'filter'
        rangeHz         % Modulation frequency range
        dsRatio         % Down-sampling ratio
        nAudioChan      % Number of audio frequency channels
        
    end
    
    properties (GetAccess = private)     % TODO: change to private once ok
        buffer          % Buffered input (for fft-based)
        
        % Downsampling
        dsProc          % Downsampling processor
        fs_ds           % Input sampling frequency after downsampling
        
        % For fft-based processing and framing in filter-based processing
        win             % Window
        overlap         % Overlap
        blockSize       % Block size
        nfft            % FFT size
        
        % For fft-based processing
        wts             % Sparse matrix for spectrogram mixing
        mn              % Index of lowest bin
        mx              % Index of higher bin
        
        % For filter-based processing
        b               % Cell array of filter coefficients
        a               % Cell array of filter coefficients
        bw              % Filters bandwidths (necessary?)
        Filters         % Cell array of filter objects
        
    end
    
    methods
        function pObj = modulationProc(fs,nChan,nFilters,range,win,blockSize,overlap,filterType,downSamplingRatio)
            % TODO:
            % - write h1
            % - expand to filter-based modulation extraction
            % - clean up
            % - make standalone? (currently uses melbankm.m)
            % - signal normalization with long-term rms (how to integrate
            % it in online-processing?)
            % - envelope normalization?
            
            
            % Check inputs
            % NB: Check that downSampleRatio is a positive integer
            
            % Check for requested type
%             if strcmp(filterType,'filter')
%                 warning('Filter-based modulation filterbank is not implemented at the moment, switching to fft-based.')
%                 filterType = 'fft';
%             end
            
            if ~strcmp(filterType,'fft') && ~strcmp(filterType,'filter')
                warning('%s is an invalid argument for modulation filterbank instantiation, switching to ''fft''.')
                filterType = 'fft';
            end
            
            % Instantiate a down-sampler if needed
            if downSamplingRatio > 1
                pObj.dsProc = downSamplerProc(fs,downSamplingRatio,1);
            end
            
            % Input sampling frequencies
            pObj.FsHzIn = fs;               % Original input sampling frequency
            pObj.fs_ds = fs/downSamplingRatio;   % Downsampled input sampling frequency
            
            
            % Generate a window
            pObj.win = window(win,blockSize);
            
            
            % Get filterbank properties
            if strcmp(filterType,'fft')
                
                % FFT-size
                fftFactor = 2;  % TODO: Hard-coded here, should this be a parameter?
                pObj.nfft = pow2(nextpow2(fftFactor*blockSize));
                % Normalized lower and upper frequencies of the mod. filterbank
                fLow = range(1)/pObj.fs_ds;
                fHigh = range(2)/pObj.fs_ds;
                [pObj.wts,pObj.modCfHz,pObj.mn,pObj.mx] = melbankm(nFilters,pObj.nfft,pObj.fs_ds,fLow,fHigh,'fs');
                
            elseif strcmp(filterType,'filter')
                
                % Get center frequencies
                cf = pow2(0:ceil(log2(pObj.fs_ds)));     % Vector of candidate center frequencies
                pObj.modCfHz = cf(cf<=range(2));    % Only take cf's within range
                pObj.modCfHz = pObj.modCfHz(pObj.modCfHz>=range(1));
                
                % Hard-coded filterbank properties
                Q = 1;              % Q-factor
                use_lp = true;      % Use low-pass filter as lowest filter
                use_hp = false;     % Use high-pass for highest filter   
                
                % Implement second-order butterworth modulation filterbank
                [pObj.b,pObj.a,pObj.bw] = createFB_Mod(pObj.fs_ds,pObj.modCfHz,Q,use_lp,use_hp);
                
                % Get bandwidths in hertz
                pObj.bw = pObj.bw*(pObj.fs_ds/2);
                
            end
            
            % Output sampling frequency (input was downsampled, and framed)
            pObj.FsHzOut = pObj.fs_ds/(blockSize-overlap);
            
           
            
            % Populate additional properties
            pObj.Type = 'Amplitude modulation extraction';
            pObj.nAudioChan = nChan;
            pObj.filterType = filterType;
            pObj.rangeHz = range;
            pObj.blockSize = blockSize;
            pObj.overlap = overlap;
            pObj.dsRatio = downSamplingRatio;
            
            % Instantiate the filters if needed
            if strcmp(pObj.filterType,'filter')
                pObj.Filters = pObj.populateFilters;
            end
            
            % Initialize buffer
            pObj.buffer = [];
            
        end
        
        function out = processChunk(pObj,in)
            % TODO:
            % - Write h1
            
            % Down-sample the input if needed
            if pObj.dsRatio > 1
                in = pObj.dsProc.processChunk(in);
            end
            
            
            
            if strcmp(pObj.filterType,'fft')
            
                % 1- Append the buffer to the input
                in = [pObj.buffer;in];  % Time spans the first dimension

                % 2- Initialize the output
                nbins = floor((size(in,1)-pObj.overlap)/(pObj.blockSize-pObj.overlap));
                out = zeros(nbins,size(in,2),size(pObj.modCfHz,2));

                % 3- Process each frequency channel and store remaining buffer
                
                for ii = 1:size(in,2)

                    % Calculate the modulation pattern for this filter
                    ams = spectrogram(in(:,ii),pObj.win,pObj.overlap,pObj.nfft);

                    % Restrain the pattern to the required mod. frequency bins
                    output = pObj.wts*abs(ams(pObj.mn:pObj.mx,:));

                    % Store it appropriately in the output
                    out(:,ii,:) = permute(output,[2 3 1]);

                    % Initialize a buffer for the first frequency channel
                    if ii == 1
                        % Initialize a temporary buffer for that chunk
                        % Buffer size might change between chunks, hence need
                        % to re-initialize it

                        % Indexes in the input of buffer start and end
                        bstart = size(output,2)*(length(pObj.win)-pObj.overlap)+1;
                        bend = size(in,1);

                        % Initialize a temporary buffer
                        temp_buffer = zeros(bend-bstart+1,size(in,2));
                    end

                    % Store the buffered input for that channel
                    temp_buffer(:,ii) = in(bstart:bend,ii);

                end

                % 4- Update the buffer from buffers collected in step 3
                pObj.buffer = temp_buffer;
                
                % TODO following is for debugging, remove!
                disp(size(pObj.buffer,1))
            
            elseif strcmp(pObj.filterType,'filter')
                
                % Initialize the output
                nbins = floor(((size(in,1)+size(pObj.buffer,1))-pObj.overlap)/(pObj.blockSize-pObj.overlap));
                out = zeros(nbins,size(in,2),size(pObj.modCfHz,2));

                % Process each frequency channel
                for ii = 1:size(in,2)
                    
                    % Calculate the modulation pattern for this audio filter
                    % Loop over number of modulation filter
                    for jj = 1:numel(pObj.modCfHz)

                        % Calculate AMS pattern of jj-th filter
                        currAMS = pObj.Filters((ii-1)*numel(pObj.modCfHz)+jj).filter(in(:,ii));
                            
                        % Append the buffer to the ams (TODO: might want to
                        % move the test out of the loops)
                        if ~isempty(pObj.buffer)
                            currAMS = [pObj.buffer(:,(ii-1)*numel(pObj.modCfHz)+jj);currAMS];
                        end
                        
                        % Frame-based analysis...
                        out(:,ii,jj) = sum(abs(frameData(currAMS,pObj.blockSize,pObj.blockSize-pObj.overlap,pObj.win,false)));

                        % Initialize a temporary buffer
                        if (ii==1) && (jj==1)
                            bstart = size(out,1)*(length(pObj.win)-pObj.overlap)+1;
                            bend = size(currAMS,1);
                            temp_buffer = zeros(bend-bstart+1,size(in,2)*numel(pObj.modCfHz));
                        end
                        
                        % Update the buffer for this audio and modulation
                        % frequencies
                        temp_buffer(:,(ii-1)*numel(pObj.modCfHz)+jj)=currAMS(bstart:bend);
                    end
                    
                end
                
                % Store the buffer
                pObj.buffer = temp_buffer;
                
                % TODO following is for debugging, remove!
                disp(size(pObj.buffer,1))
                
            end
                
            
        end
        
        function reset(pObj)
            % TODO: 
            % - write h1
            
            % Reset the buffer
            pObj.buffer = [];
            
            % Reset the filters states if needed
            if strcmp(pObj.filterType,'filter')
                for ii = 1:size(pObj.Filters)
                    pObj.Filters(ii).reset;
                end
            end
            
        end
        
        function hp = hasParameters(pObj,p)
            % TODO:
            % - implement once parameters are clearly defined
            % - h1
            
            warning('Not implemented yet, returning true')
            hp = 1;
        end
            
        
    end
    
    methods (Access = private)
        function obj = populateFilters(pObj)
            % This function is a workaround to assign an array of objects
            % as one of the processor's property, should remain private

            % Total number of filters
            nFilter = numel(pObj.modCfHz)*pObj.nAudioChan;
            
            % Preallocate memory by instantiating last filter
            obj(1,nFilter) = genericFilter(pObj.b{end},pObj.a{end},pObj.fs_ds);
            
            % Instantiating remaining filters
            for ii = 0:pObj.nAudioChan-1
                for jj = 1:numel(pObj.modCfHz)
                    obj(1,ii*numel(pObj.modCfHz)+jj) = genericFilter(pObj.b{jj},pObj.a{jj},pObj.fs_ds);
                end
            end                        
            
        end
    end
    
    
end