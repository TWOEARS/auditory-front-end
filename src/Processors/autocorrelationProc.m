classdef autocorrelationProc < Processor
    
    properties 
        wname       % Window shape descriptor (see window.m)
        wSizeSec    % Window duration in seconds
        hSizeSec    % Step size between windows in seconds
        clipMethod  % Center clipping method ('clc','clp','sgn')
        alpha       % Threshold coefficient in center clipping
        K           % Exponent in auto-correlation
    end
    
    properties (GetAccess = private)
        wSize       % Window duration in samples
        hSize       % Step size between windows in samples
        win         % Window vector
        buffer      % Buffered input signals for framing
        do_mex      % Flag indicating the use of the Tobias' mex code
    end
    
    methods
        function pObj = autocorrelationProc(fs,p,do_mex)
            %autocorrelationProc    Constructs an auto-correlation
            %                       processor
            %
            %USAGE
            %  pObj = autocorrelation(fs)
            %  pObj = autocorrelation(fs,p)
            %
            %INPUT PARAMETERS
            %    fs : Sampling frequency (Hz)
            %     p : Structure of non-default parameters
            %
            %OUTPUT PARAMETERS
            %  pObj : Processor Object
            
            
            if nargin>0 % Safeguard for Matlab empty calls
               
            % Checking input parameters
            if nargin<3||isempty(do_mex);do_mex = 1;end
            if nargin<2||isempty(p)
                p = getDefaultParameters(fs,'processing');
            else
                p = parseParameters(p);
            end
            if isempty(fs)
                error('Sampling frequency needs to be provided')
            end
            
            % Populate properties
            pObj.wname = p.ac_wname;
            pObj.wSizeSec = p.ac_wSizeSec;
            pObj.wSize = 2*round(pObj.wSizeSec*fs/2);
            pObj.hSizeSec = p.ac_hSizeSec;
            pObj.hSize = round(pObj.hSizeSec*fs);
            pObj.win = window(pObj.wname,pObj.wSize);
            pObj.clipMethod = p.ac_clipMethod;
            pObj.alpha = p.ac_clipAlpha;
            pObj.K = p.ac_K;
            
            pObj.Type = 'Auto-correlation extractor';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = 1/(pObj.hSizeSec);
            pObj.do_mex = do_mex;
            
            % Initialize buffer
            pObj.buffer = [];
                
            end
        end
        
        function out = processChunk(pObj,in)
            %processChunk       Apply the processor to a new chunk of input
            %                   signal
            %
            %USAGE
            %   out = pObj.processChunk(in)
            %
            %INPUT ARGUMENT
            %    in : New chunk of input data
            %
            %OUTPUT ARGUMENT
            %   out : Corresponding output
            %
            %NOTE: This method does not control dimensionality of the
            %provided input. If called outside of a manager instance,
            %validity of the input is the responsibility of the user!
            
           
            % Append the input to existing buffer
            if ~isempty(pObj.buffer)
                in = [pObj.buffer;in];
            end
            
            % Get dimensionality of buffered input
            [nSamples,nChannels] = size(in);
            
            % How many frames are in the buffered input?
            nFrames = floor((nSamples-(pObj.wSize-pObj.hSize))/pObj.hSize);
            
            % Determine maximum lag
            M = pObj.wSize;     % Frame size in samples
            maxLag = M-1;      % Maximum lag in computation

            % Pre-allocate output
            out = zeros(nFrames,nChannels,maxLag);            
            
            if ~pObj.do_mex
                % Loop on the frames
                for ii = 1:nFrames
                    % Get start and end indexes for the current frame
                    n_start = (ii-1)*pObj.hSize+1;
                    n_end = (ii-1)*pObj.hSize+pObj.wSize;

                    % Loop on the channel
                    for jj = 1:nChannels

                        % Extract current frame
                        frame = pObj.win.*in(n_start:n_end,jj);
                        
                        % Perform center clipping
                        frame = applyCenterClipping(frame,pObj.clipMethod,pObj.alpha);
                        
                        % Compute auto-correlation:

                        % Get the frame in the Fourier domain
                        XX = abs(fft(frame,2^nextpow2(2*M-1))).^pObj.K;

                        % Back to time domain
                        x = real(ifft(XX));

                        % Normalize by auto-correlation at lag zero
                        x = x/x(1);

                        % Store results for positive lags only
                        out(ii,jj,:) = x(1:M);

                    end

                end
                
            else
                % Use Tobias previous code
                
                % Loop on the auditory channels
                for jj = 1:nChannels
                    
                    % Framing using mex
                    frames = frameData(in(:,jj),pObj.wSize,pObj.hSize,pObj.win,false);
                    
                    % Perform center clipping
                    frames = applyCenterClipping(frames,pObj.clipMethod,pObj.alpha);
                    
                    % Auto-correlation analysis
                    acf = calcACorr(frames,maxLag,'coeff',pObj.K);
                    
                    % Store results for positive lags only
                    out(:,jj,:) = permute(acf,[2 3 1]);
                    
                end
            end

            
        end
        
        function reset(pObj)
            %reset      Resets the auto-correlation processor (cleans the
            %           internal buffer)
            %
            %USAGE
            %   pObj.reset
            %   pObj.reset()
            %
            %INPUT ARGUMENT
            % pObj : Auto-correlation processor instance
            
            % Empty the buffer
            pObj.buffer = [];
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
            
            
            p_list_proc = {'wname','wSizeSec','hSizeSec','clipMethod','alpha','K'};
            p_list_par = {'ac_wname','ac_wSizeSec','ac_hSizeSec','ac_clipMethod','ac_clipAlpha','ac_K'};
            
            % Initialization of a parameters difference vector
            delta = zeros(size(p_list_proc,2),1);
            
            % Loop on the list of parameters
            for ii = 1:size(p_list_proc,2)
                try
                    if ischar(pObj.(p_list_proc{ii}))
                        delta(ii) = ~strcmp(pObj.(p_list_proc{ii}),p.(p_list_par{ii}));
                    else
                        delta(ii) = abs(pObj.(p_list_proc{ii}) - p.(p_list_par{ii}));
                    end
                    
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
    
    
end