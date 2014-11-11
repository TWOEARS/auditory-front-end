classdef crosscorrelationProc < Processor
    
    properties
        wname       % Window shape descriptor (see window.m)
        wSizeSec    % Window duration in seconds
        hSizeSec    % Step size between windows in seconds
        maxDelaySec % Maximum delay in cross-correlation computation (s)
        do_mex      % TEMP flag indicating the use of the Tobias' mex code (1)
    end
    
    properties (GetAccess = private)
        wSize       % Window duration in samples
        hSize       % Step size between windows in samples
        win         % Window vector
        lags        % Vector of lags at which cross-correlation is computed
        buffer_l    % Buffered input signals (left ear)
        buffer_r    % Buffered input signals (right ear)
    end
        
    methods
        
        function pObj = crosscorrelationProc(fs,p,do_mex)
            %crosscorrelationProc    Constructs a cross-correlation
            %                        processor
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
            
            if nargin>0     % Safeguard for Matlab empty calls
            
            % Checking input parameter
            if nargin<2||isempty(p)
                p = getDefaultParameters(fs,'processing');
            end
            if isempty(fs)
                error('Sampling frequency needs to be provided')
            end
            
            % Populate properties
            pObj.wname = p.cc_wname;
            pObj.wSizeSec = p.cc_wSizeSec;
            pObj.wSize = 2*round(pObj.wSizeSec*fs/2);
            pObj.hSizeSec = p.cc_hSizeSec;
            pObj.hSize = round(pObj.hSizeSec*fs);
            pObj.win = window(pObj.wname,pObj.wSize);
            pObj.Type = 'Cross-correlation extractor';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = 1/(pObj.hSizeSec);
            pObj.maxDelaySec = p.cc_maxDelaySec;
            pObj.isBinaural = true;
            
            % TEMP:
            pObj.do_mex = do_mex;
            
            % Initialize buffer
            pObj.buffer_l = [];
            pObj.buffer_r = [];
            
            end
            
        end
        
        function out = processChunk(pObj,in_l,in_r)
            %processChunk   Calls the processing for a new chunk of signal
            %
            %USAGE
            %   out = pObj.processChunk(in_l,in_r)
            %
            %INPUT ARGUMENTS
            %  pObj : Processor instance
            %  in_l : Left-ear input (inner hair-cell envelope)
            %  in_r : Right-ear input (inner hair-cell envelope)
            %
            %OUTPUT ARGUMENT
            %   out : Resulting output
            
            % Append provided input to the buffer
            if ~isempty(pObj.buffer_l)
                in_l = [pObj.buffer_l;in_l];
                in_r = [pObj.buffer_r;in_r];
            end
            
            % Quick control of dimensionality
            if max(size(in_l)~=size(in_r))
                error('Buffered inputs should be of same dimension for both ears')
            end
            
            [nSamples,nChannels] = size(in_l);
            
            % How many frames are in the buffered input?
            nFrames = floor((nSamples-(pObj.wSize-pObj.hSize))/pObj.hSize);
            
            % Determine maximum lag in samples
            maxLag = ceil(pObj.maxDelaySec*pObj.FsHzIn);
            
            % Pre-allocate output
            if ~pObj.do_mex

            out = zeros(nFrames,nChannels,maxLag*2+1);
            % Loop on the time frame
            for ii = 1:nFrames
                % Get start and end indexes for the current frame
                n_start = (ii-1)*pObj.hSize+1;
                n_end = (ii-1)*pObj.hSize+pObj.wSize;
                
                % Loop on the channel
                for jj = 1:nChannels
                    
                    % Extract frame for left and right input
                    frame_l = pObj.win.*in_l(n_start:n_end,jj);
                    frame_r = pObj.win.*in_r(n_start:n_end,jj);
                    
                    % Compute the frames in the Fourier domain
                    X = fft(frame_l,2^nextpow2(2*pObj.wSize-1));
                    Y = fft(frame_r,2^nextpow2(2*pObj.wSize-1));
                    
                    % Compute cross-power spectrum
                    XY = X.*conj(Y);
                    
                    % Back to time domain
                    c = real(ifft(XY));
                    
                    % Vector of lags 
                    pObj.lags = (-maxLag:maxLag).';
                    
                    % Adjust to requested maximum lag and move negative
                    % lags upfront
                    if maxLag >= pObj.wSize
                        % Then pad with zeros
                        pad = zeros(maxLag-pObj.wSize+1,1);
                        c = [pad;c(end-pObj.wSize+2:end);c(1:pObj.wSize);pad];
                    else
                        % Else keep lags lower than requested max
                        c = [c(end-maxLag+1:end);c(1:maxLag+1)];
                    end
                    
                    % Normalize with autocorrelation at lag zero and store
                    % output
                    powL = sum(frame_l.^2);
                    powR = sum(frame_r.^2);
                    out(ii,jj,:) = c/sqrt(powL*powR+eps);
                    
                end
                
            end

            else
            out = zeros(max(1,nFrames),nChannels,maxLag*2+1);
                % Use Tobias mex code for framing
                for jj = 1:nChannels

                    % Framing
                    frames_L = frameData(in_l(:,jj),pObj.wSize,pObj.hSize,pObj.win,false);
                    frames_R = frameData(in_r(:,jj),pObj.wSize,pObj.hSize,pObj.win,false);

                    % Cross-correlation analysis
                    output = calcXCorr(frames_L,frames_R,maxLag,'coeff');

%                     % Cross-correlation analysis
%                     [output,lags] = calcXCorr(frames_L,frames_R,maxLag,'none');
% 
%                     % Normalization
%                     output = output ./ repmat(eps + sqrt(sum(frames_L.^2,1) .* sum(frames_R.^2,1)),[2*maxLag+1 1]);
% 
%                     scale = pObj.wSize-abs(lags'); scale(scale<=0)=1;
%                     
%                     output = output ./ repmat(scale(:)/max(scale),[1 nFrames]);
                    
                    % Store output
                    out(:,jj,:) = permute(output,[2 3 1]);
                    
                end
            end
            
            % Update the buffer: the input that was not extracted as a
            % frame should be stored
            pObj.buffer_l = in_l(nFrames*pObj.hSize+1:end,:);
            pObj.buffer_r = in_r(nFrames*pObj.hSize+1:end,:);
            
        end
        
        function reset(pObj)
             %reset     Resets the internal states of the processor
             %
             %USAGE
             %      pObj.reset
             %
             %INPUT ARGUMENTS
             %  pObj : Cross-correlation processor instance
             
             % Only thing needed to reset is to empty the buffers
             pObj.buffer_l = [];
             pObj.buffer_r = [];
             
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
            
            %NB: Could be moved to private?
            
            p_list_proc = {'wname','wSizeSec','hSizeSec','maxDelaySec'};
            p_list_par = {'cc_wname','cc_wSizeSec','cc_hSizeSec','cc_maxDelaySec'};
            
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