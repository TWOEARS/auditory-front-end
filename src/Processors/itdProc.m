classdef itdProc < Processor
%ITDPROC Interaural Time Difference processor.
%   This processor estimates the time difference between the left and the
%   right ear signals for individual frequency channels and time frames by
%   locating the time lag that corresponds to the most prominent peak in
%   the normalized cross-correlation function. This estimation is further 
%   refined by a parabolic interpolation stage [1].
%
%   ITDPROC properties:
%       frameFsHz       - Sampling frequency of the signal (see below)
%
%   See also: Processor, crosscorrelationProc
%
%   Reference:
%   [1] May, T., van de Par, S., and Kohlrausch, A. (2011), "A probabilistic 
%       model for robust localization based on a binaural auditory front-end,¡± 
%       IEEE Transactions on Audio, Speech, and Language Processing 19(1), 
%       pp. 1?13.

    properties (GetAccess = private)
        frameFsHz   % Sampling frequency of the signal before framing, used 
                    %   for expressing ITDs in seconds
    end
    
    methods
        
        function pObj = itdProc(fs,p)
            %icProc     Constructs an interaural correlation processor
            %
            %USAGE
            %  pObj = icProc(fs)
            %  pObj = icProc(fs,p)
            %
            %INPUT PARAMETERS
            %    fs : Sampling frequency (Hz)
            %     p : Set of non-default parameters
            %
            %OUTPUT PARAMETERS
            %  pObj : Processor object
            
            if nargin>0     % Safeguard for Matlab empty calls
                
            % Checking input parameter
            if nargin<2||isempty(p)
                p = getDefaultParameters(fs,'processing');
                % Temporary warning while no adequate parameter handling
                warning('ITDs are normally obtained from down-sampled signals, check your sampling frequencies')
            end
            if isempty(fs)
                error('Sampling frequency needs to be provided')
            end
            
            % Populate properties
            pObj.populateProperties('Type','ITD extractor',...
                'FsHzIn',fs,'FsHzOut',fs);
            
            pObj.frameFsHz = p.fs;
                
            end
        end
        
        function out = processChunk(pObj,in)
            %processChunk   Calls the processing for a new chunk of signal
            %
            %USAGE
            %   out = pObj.processChunk(in)
            %
            %INPUT ARGUMENT
            %  pObj : Processor instance
            %    in : Input (cross-correlation)
            %
            %OUTPUT ARGUMENT
            %   out : Corresponding output
            
            % Dimensionality of the input
            [nFrames,nChannels,nLags] = size(in);
            
            % Pre-allocate output
            out = zeros(nFrames,nChannels);
            
            % Create a lag vector
            lags = (0:nLags-1).'-(nLags-1)/2;
            
            % Loop over the time frame
            for ii = 1:nFrames
                
                % Loop over the frequency channel
                for jj = 1:nChannels
                    
                    % Find the peak in the discretized crosscorrelation
                    [c,i] = max(in(ii,jj,:));
                    
                    % Lag of most salient peak
                    lagInt = lags(i);
                    
                    if i>1 && i<nLags
                        % Then interpolate using neighbor points
                        c_l = in(ii,jj,i-1);    % Lower neighbor
                        c_u = in(ii,jj,i+1);    % Upper neighbor
                        
                        % Estimate "true" peak deviation through parabolic
                        % interpolation
                        delta = 0.5*(c_l-c_u)/(c_l-2*c+c_u);
                        
                        % Store estimate
                        out(ii,jj) = (lagInt + delta)/pObj.frameFsHz;
                        
                    else
                        % Do not interpolate if the peak is at a boundary
                        out(ii,jj) = lagInt/pObj.frameFsHz;
                    end
                    
                end
            end
        end
        
        function reset(pObj)
            % Nothing to reset for that processor, but this abstract method
            % has to be implemented to make this class concrete.
        end
        
        function hp = hasParameters(pObj,p)
            % This processor has no additional parameters, always return
            % true.
            
            hp = true;
        end
          
    end
    
end