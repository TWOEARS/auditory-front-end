classdef modulationProc < Processor
    
    properties
        modCfHz         % Modulation filters center frequencies
        type            % 'fft' vs. 'filter'
        rangeHz         % Modulation frequency range
        dsRatio         % Down-sampling ratio
        
    end
    
    properties (GetAccess = public)     % TODO: change to private once ok
        buffer          % Buffered input (for fft-based)
        
        % Downsampling
        dsProc          % Downsampling processor
        
        % For fft-based filtering
        win             % Window
        overlap         % Overlap
        blockSize       % Block size
        nfft            % FFT size
        
        wts             % Sparse matrix for spectrogram mixing
        modCf           % Modulation frequency bins
        mn              % Index of lowest bin
        mx              % Index of higher bin
        
    end
    
    methods
        function pObj = modulationProc(fs,nFilters,range,win,blockSize,overlap,type,downSamplingRatio)
            % TODO:
            % - write h1
            % - expand to filter-based modulation extraction
            % - clean up
            % - make standalone? (currently uses melbankm.m)
            % - integrate in manager (implies changing getDependencies,
            %                           etc...)
            
            
            % Check inputs
            % NB: Check that downSampleRatio is a positive integer
            
            % Check for requested type
            if strcmp(type,'filter')
                warning('Filter-based modulation filterbank is not implemented at the moment, switching to fft-based.')
                type = 'fft';
            end
            
            if ~strcmp(type,'fft')
                warning('%s is an invalid argument for modulation filterbank instantiation, switching to ''fft''.')
                type = 'fft';
            end
            
            % Instantiate a down-sampler if needed
            if downSamplingRatio > 1
                pObj.dsProc = downSamplerProc(fs,downSamplingRatio,1);
            end
            
            % FFT-size
            fftFactor = 2;  % TODO: Hard-coded here, should this be a parameter?
            pObj.nfft = pow2(nextpow2(fftFactor*blockSize));
            
            % Generate a window
            pObj.win = window(win,blockSize);
            
            % Normalized lower and upper frequencies of the mod. filterbank
            fLow = range(1)/fs;
            fHigh = range(2)/fs;
            
            % Get fft-based filterbank properties
            [pObj.wts,pObj.modCfHz,pObj.mn,pObj.mx] = melbankm(nFilters,pObj.nfft,fs,fLow,fHigh,'fs');
            
            % Populate additional properties
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs/downSamplingRatio;
            pObj.type = type;
            pObj.rangeHz = range;
            pObj.blockSize = blockSize;
            pObj.overlap = overlap;
            pObj.dsRatio = downSamplingRatio;
            
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
            
            
        end
        
        function reset(pObj)
            % TODO: 
            % - write h1
            
            % Only need to reset the buffer
            pObj.buffer = [];
            
        end
        
        function hp = hasParameters(pObj,p)
            % TODO:
            % - implement once parameters are clearly defined
            % - h1
            
            warning('Not implemented yet, returning true')
            hp = 1;
        end
            
        
    end
    
    
end