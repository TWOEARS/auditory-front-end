classdef modulationProc < Processor
    
    properties
        modCfHz         % Modulation filters center frequencies
        filterType      % 'lin' vs. 'log'
        
        winName         % Window
        stepSec         % Step size in seconds
        blockSec        % Block size in seconds
        
        dsRatio         % Down-sampling ratio
        nAudioChan      % Number of audio frequency channels
    end
    
    properties (GetAccess = private)
        buffer          % Buffered input (for fft-based)
        nModChan        % Number of modulation channels
        
        lowFreqHz       % Lowest modulation center frequency 
        highFreqHz      % Highest modulation center frequency 
        
        overlap         % Overlap in samples
        blockSize       % Block size in samples

        % Downsampling
        dsProc          % Downsampling processor
        fs_ds           % Input sampling frequency after downsampling
        
        % For fft-based processing and framing in filter-based processing
        nfft            % FFT size
        win             % Window vector
        
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
        
        function pObj = modulationProc(fs,nChan,cfHz,nFilters,lowFreqHz,highFreqHz,win,blockSec,stepSec,fbType,downSamplingRatio)
            %modulationProc     Instantiate an amplitude modulation
            %                   extractor
            %
            %USAGE:
            %  pObj = modulationProc(fs,nChan,cfHz,nFilters,lowFreqHz,highFreqHz,win,blockSec,stepSec,fbType,dsRatio)
            %
            %INPUT ARGUMENTS:
            %         fs : Sampling frequency of the input (Hz)
            %      nChan : Number of audio frequency channels
            %       cfHz : Vector of modulation center frequencies (Hz)
            %   nFilters : Number of modulation frequency bins
            %  lowFreqHz : Lowest modulation center frequency (Hz)
            % highFreqHz : Highest modulation center frequency (Hz)
            %        win : Window shape used for framing
            %   blockSec : Block size of AMS features (s)
            %    stepSec : Step size of AMS features (s)
            %     fbType : Type of modulation filterbank, 'lin' for
            %              FFT-based, or 'log' for filter-based implementation
            %    dsRatio : Downsampling ratio 
            %
            %OUTPUT ARGUMENT:
            %       pObj : Processor instance
            
            
            % TODO:
            % - make standalone? (currently uses melbankm.m and createFB_Mod.m)
            % - signal normalization with long-term rms (how to integrate
            % it in online-processing?)
            % - envelope normalization?
            
            
            % Check inputs
            if mod(downSamplingRatio,1)~=0 || downSamplingRatio < 1
                error('The down sampling ratio should be a positive integer')
            end
            
            if ~strcmp(fbType,'lin') && ~strcmp(fbType,'log')
                warning('%s is an invalid argument for modulation filterbank instantiation, switching to ''log''.')
                fbType = 'log';
            end
            
            % Instantiate a down-sampler if needed
            if downSamplingRatio > 1
                pObj.dsProc = downSamplerProc(fs,downSamplingRatio,1);
            end
            
            % Input sampling frequencies
            pObj.FsHzIn = fs;                   % Original input sampling frequency
            pObj.fs_ds  = fs / downSamplingRatio;  % Downsampled input sampling frequency
                     
            if highFreqHz > pObj.fs_ds/2
                error('Highest modulation center frequency is above nyquist frequency. Either reduce the downsampling ratio or decrease the upper frequency limit. ')
            end
            
            % Set default values
            if isempty(blockSec)
                blockSec = 32E-3;
            end
            if isempty(blockSec)
                stepSec = 16E-3;
            end
            if isempty(win)
                win = 'hamming';
            end
            
            % Compute framing parameters
            blockSamples    = 2 * round(blockSec * pObj.fs_ds / 2);
            stepSizeSamples = round(blockSamples / (blockSec/stepSec));
            overlapSamples  = blockSamples - stepSizeSamples;
            pObj.winName    = win;                 % Generate a window
            pObj.win = window(win,blockSamples);
            
            pObj.blockSec = blockSec;
            pObj.stepSec  = stepSec;
            
            % Get filterbank properties
            if strcmp(fbType,'lin')
                
                if isempty(cfHz)
                    % FFT-size
                    fftFactor = 2;  
                    pObj.nfft = pow2(nextpow2(fftFactor*blockSamples));
                    
                    if isempty(lowFreqHz);
                        lowFreqHz = 0;
                    end
                    if isempty(highFreqHz);
                        highFreqHz = 400;
                    end
                    if isempty(nFilters)
                        nFilters = 15;
                    end
                    
                    % Normalized lower and upper frequencies of the mod. filterbank
                    fLow  = lowFreqHz  / pObj.fs_ds;
                    fHigh = highFreqHz / pObj.fs_ds;
                    [pObj.wts,pObj.modCfHz,pObj.mn,pObj.mx] = melbankm(nFilters,pObj.nfft,pObj.fs_ds,fLow,fHigh,'fs');
                else
                    error('The specification of center frequencies is not supported by the FFT-based method')
                end
                    
            elseif strcmp(fbType,'log')
                
                % Get center frequencies
                if isempty(cfHz)
                     if isempty(lowFreqHz);
                        lowFreqHz = 4;
                    end
                    if isempty(highFreqHz);
                        highFreqHz = 1024;
                    end
                    
                    pObj.modCfHz = createFreqAxisLog(lowFreqHz,highFreqHz,nFilters);
                else
                    % Overwrite frequency range
                    pObj.modCfHz = cfHz;
                    
                    lowFreqHz  = min(cfHz);
                    highFreqHz = max(cfHz);
                end
        
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
            pObj.FsHzOut = pObj.fs_ds/stepSizeSamples;
         
            
            % Populate additional properties
            pObj.Type = 'Amplitude modulation spectrogram extraction';
            pObj.nAudioChan = nChan;
            pObj.filterType = fbType;
            pObj.lowFreqHz = lowFreqHz;
            pObj.highFreqHz = highFreqHz;
            pObj.blockSize = blockSamples;
            pObj.overlap = overlapSamples;
            pObj.dsRatio = downSamplingRatio;
            pObj.nModChan = numel(pObj.modCfHz);
            
            % Instantiate the filters if needed
            if strcmp(pObj.filterType,'log')
                pObj.Filters = pObj.populateFilters;
            end
            
            % Initialize buffer
            pObj.buffer = [];
            
        end
        
        function out = processChunk(pObj,in)
            %processChunk       Requests the processing for a new chunk of
            %                   signal
            %
            %USAGE:
            %    out = processChunk(in)
            %
            %INPUT ARGUMENTS:
            %   pObj : Processor instance
            %     in : Input chunk
            %
            %OUTPUT ARGUMENT:
            %    out : Processor output for that chunk
            
            
            % Down-sample the input if needed
            if pObj.dsRatio > 1
                in = pObj.dsProc.processChunk(in);
            end
            
            if strcmp(pObj.filterType,'lin')
            
                % 1- Append the buffer to the input
                in = [pObj.buffer;in];  % Time spans the first dimension

                % 2- Initialize the output
                nbins = max(floor((size(in,1)-pObj.overlap)/(pObj.blockSize-pObj.overlap)),0);
                out = zeros(nbins,size(in,2),size(pObj.modCfHz,2));

                % 3- Process each frequency channel and store remaining buffer
                
                % Process if the input is long enough (spectrogram returns
                % an error if the input is shorter than one window)
                if nbins > 0

                    for ii = 1:size(in,2)

                        % Calculate the modulation pattern for this filter
                        ams = spectrogram(in(:,ii),pObj.win,pObj.overlap,pObj.nfft);

                        % Normalize spectrogram
                        ams = ams / pObj.nfft;
                        
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

                % If not, then buffer the all input signal    
                else
                    temp_buffer = in;
                end
                    
                % 4- Update the buffer from buffers collected in step 3
                pObj.buffer = temp_buffer;
                
            
            elseif strcmp(pObj.filterType,'log')
                
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
                        % move the isempty test out of the loops)
                        if ~isempty(pObj.buffer)
                            currAMS = [pObj.buffer(:,(ii-1)*numel(pObj.modCfHz)+jj);currAMS];
                        end
                        
                        % Frame-based analysis...
                        out(:,ii,jj) = mean(abs(frameData(currAMS,pObj.blockSize,pObj.blockSize-pObj.overlap,pObj.win,false)));

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
                
            end
                
        end
        
        function reset(pObj)
            %reset      Resets the internal states of the processor
            %
            %USAGE:
            %    pObj.reset
            % 
            %INPUT ARGUMENT:
            %    pObj : Processor instance
           
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
            %hasParameters  This method compares the parameters of the
            %               processor with the parameters given as input
            %
            %USAGE
            %    hp = pObj.hasParameters(p)
            %
            %INPUT ARGUMENTS
            %  pObj : Processor instance
            %     p : Structure containing parameters to test
           
            
            % Only the parameters needed to instantiate the processor need
            % to be compared
            p_list_proc = {'modCfHz','nModChan','lowFreqHz','highFreqHz','filterType','winName','blockSec','stepSec','dsRatio'};
            p_list_par = {'ams_cfHz','ams_nFilters','ams_lowFreqHz','ams_highFreqHz','ams_fbType','ams_wname','ams_wSizeSec','ams_hSizeSec','ams_dsRatio'};
            
%             % Number of channels is irrelevant for 'filter'-based
%             % implementation, only the range matters
%             if strcmp(p.am_type,'filter')
%                 p_list_proc = setdiff(p_list_proc,'nModChan','stable');
%                 p_list_par = setdiff(p_list_par,'am_nFilters','stable');
%             end
            
            % Initialization of a parameters difference vector
            delta = zeros(size(p_list_proc,2),1);
            
            % Loop on the list of parameters
            for ii = 1:size(p_list_proc,2)
                try
                    delta(ii) = ~isequal(pObj.(p_list_proc{ii}),p.(p_list_par{ii}));
                    
                    
                catch err
                    % Warning: something is missing
                    warning('Parameter %s is missing in input p.',p_list_par{ii})
                    delta(ii) = 1;
                end
            end
            
            % Check if delta is a vector of zeros
            if max(delta)>0
                hp = false;
            else
                hp = true;
            end
            
            
            
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