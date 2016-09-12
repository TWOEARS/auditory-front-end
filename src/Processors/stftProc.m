classdef stftProc < Processor
    %stftProc Processor providing STFT of a time-domain ear signal.
    %
    % Returns the complex STFT time frequency spectrum per frame.
    %
    % TODO: some reference
    %
    
    %% Properties
    properties (Dependent = true)
        wSizeSec    % window size in seconds
        hSizeSec    % window shift in seconds
    end
    
    properties (GetAccess = protected)
        wSize       % window size in samples
        hSize       % window shift in samples
        nFFT        % # of FFT frequency bins
        win         % window vector
        buffer      % unframed remainder of input
    end
    
    properties (SetAccess = protected)
        cfHz        % fft frequencies for output annotation
    end
    
    %% Methods
    methods
        
        function pObj = stftProc(fs, parObj)
            %stftProc   constructor
            
            if nargin<2 || isempty(parObj); parObj = Parameters; end
            if nargin<1; fs = []; end
            
            % Call super-constructor
            pObj = pObj@Processor(fs, fs, 'stftProc', parObj);
            
            if nargin>0
                pObj.buffer = [];
            end
            
        end
        
        function out = processChunk(pObj, in)
            %processChunk   main compute context
            
            % prepend buffer content to data
            if ~isempty(pObj.buffer)
                in = [pObj.buffer; in];
            end
            
            % prepare frames and storage
            nSamples = size(in, 1);
            nFrames = floor((nSamples-(pObj.wSize-pObj.hSize))/pObj.hSize);
            out = zeros(nFrames, pObj.nFFT);
            
            % STFT over frames
            for ii = 1:nFrames
                % frame start and end indices
                fr_start = (ii-1)*pObj.hSize+1;
                fr_end = (ii-1)*pObj.hSize+pObj.wSize;
                % frame data with windowing function
                frame = pObj.win.*in(fr_start:fr_end);
                % compute frame FFT
                out(ii,:) = fft(frame, pObj.nFFT);
            end
            
            % save remaining time samples to buffer
            pObj.buffer = in(nFrames*pObj.hSize+1:end,:);            
        end
        
        function reset(pObj)
            %reset   reset internal buffer
            
            pObj.buffer = [];
            
        end
        
    end
    
    %% "Overridden" methods
    methods (Hidden = true)
        
        function prepareForProcessing(pObj)            
            pObj.wSize = 2*round(pObj.parameters.map('stft_wSizeSec')*pObj.FsHzIn/2);
            pObj.hSize = round(pObj.parameters.map('stft_hSizeSec')*pObj.FsHzIn);
            pObj.win = hamming(pObj.wSize,'periodic');
            pObj.nFFT = max(256,2^nextpow2(2*pObj.wSize-1));
            pObj.FsHzOut = 1/(pObj.hSizeSec);
            pObj.cfHz = [(0:pObj.nFFT/2) ((-pObj.nFFT/2)+1):-1]*pObj.FsHzIn/pObj.nFFT;            
        end
        
    end
    
    %% "Getter" methods
    methods
        
        function wSizeSec = get.wSizeSec(pObj)
            wSizeSec = pObj.parameters.map('stft_wSizeSec');
        end
        
        function hSizeSec = get.hSizeSec(pObj)
            hSizeSec = pObj.parameters.map('stft_hSizeSec');
        end
        
    end
    
    %% Static methods
    methods (Static)
        
        function dep = getDependency()
            dep = 'time';
        end
        
        function [names, defaultValues, descriptions] = getParameterInfo()
            %getParameterInfo   Returns the parameter names, default values
            %                   and descriptions for that processor
            %
            %USAGE:
            %  [names, defaultValues, description] =  ...
            %                           gammatoneProc.getParameterInfo;
            %
            %OUTPUT ARGUMENTS:
            %         names : Parameter names
            % defaultValues : Parameter default values
            %  descriptions : Parameter descriptions
            
            names = {...
                'stft_wSizeSec',...
                'stft_hSizeSec'};
            
            descriptions = {...
                'Window duration (s)',...
                'Window step size (s)'};
            
            defaultValues = {...
                20E-3,...
                10E-3};
        end
        
        function pInfo = getProcessorInfo()
            
            pInfo = struct;
            
            pInfo.name = 'STFT';
            pInfo.label = 'STFT features';
            pInfo.requestName = 'stft';
            pInfo.requestLabel = 'Short-Time-Fourier-Transform Features';
            pInfo.outputType = 'STFTSignal';
            pInfo.isBinaural = false;
        end
        
    end
    
end
