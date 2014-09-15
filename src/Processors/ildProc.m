classdef ildProc < Processor
    
    properties
        wname       % Window shape descriptor (see window.m)
        wSizeSec    % Window duration in seconds
        hSizeSec    % Step size between windows in seconds
        isBinaural  % Flag indicating the need for two channels
    end
    
    properties (GetAccess = private)
        wSize       % Window duration in samples
        hSize       % Step size between windows in samples
        win         % Window vector
        buffer_l    % Buffered input signals (left ear)
        buffer_r    % Buffered input signals (right ear)
    end
    
    methods
        function pObj = ildProc(fs,p)
            %ildProc    Constructs an ILD extraction processor
            %
            %USAGE
            %   pObj = ildProc(fs)
            %   pObj = ildProc(fs,p)
            %
            %INPUT PARAMETERS
            %   fs : Sampling frequency in Hz
            %    p : Structure of non-default parameters
            %
            %OUTPUT PARAMETER
            % pObj : Processor object
            
            % TO DO: Document parameter handling once implemented
            
            if nargin>0     % Safeguard for Matlab empty calls
            
            % Checking input parameter
            if nargin<2||isempty(p)
                p = getDefaultParameters(fs,'processing');
            end
            if isempty(fs)
                error('Sampling frequency needs to be provided')
            end
            
            % Populate properties
            pObj.wname = p.ild_wname;
            pObj.wSizeSec = p.ild_wSizeSec;
            pObj.wSize = 2*round(pObj.wSizeSec*fs/2);
            pObj.hSizeSec = p.ild_hSizeSec;
            pObj.hSize = round(pObj.hSizeSec*fs);
            pObj.win = window(pObj.wname,pObj.wSize);
            pObj.Type = 'ILD extractor';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = 1/(pObj.hSizeSec);
            
            % Initialize buffer
            pObj.buffer_l = [];
            pObj.buffer_r = [];
            
            end
        end
        
        function out = processChunk(pObj,in_l,in_r)
            %processChunk
            %
            %TO DO:
            % - Do we need a h1 line here?
            % - Do we need to check inputs dimensionality?
            % - Better handling of dimensionality problem
            
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
            
            % Compute ILDs:
            
            % Pre-allocate output
            out = zeros(nFrames,nChannels);
            
            % Loop on the time frame
            for ii = 1:nFrames
                % Get start and end indexes for the current frame
                n_start = (ii-1)*pObj.hSize+1;
                n_end = (ii-1)*pObj.hSize+pObj.wSize;
                
                % Loop on the channel
                for jj = 1:nChannels
                    
                    % Energy in the windowed frame for left and right input
                    frame_l = mean(power(pObj.win.*in_l(n_start:n_end,jj),2));
                    frame_r = mean(power(pObj.win.*in_r(n_start:n_end,jj),2));
                    
                    % Compute the ild for that frame
                    out(ii,jj) = 10*log10((frame_r+eps)/(frame_l+eps));
                    
                end
                
            end
            
            % Update the buffer: the input that was not extracted as a
            % frame should be stored
            pObj.buffer_l = in_l(nFrames*pObj.hSize+1:end,:);
            pObj.buffer_r = in_r(nFrames*pObj.hSize+1:end,:);
            
            
        end
        
        function reset(pObj)
             %reset     Resets the internal states of the ILD extractor
             %
             %USAGE
             %      pObj.reset
             %
             %INPUT ARGUMENTS
             %  pObj : ILD extractor processor instance
             
             % Only thing needed to reset is to empty the buffer
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
            
            p_list_proc = {'wname','wSizeSec','hSizeSec'};
            p_list_par = {'ild_wname','ild_wSizeSec','ild_hSizeSec'};
            
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