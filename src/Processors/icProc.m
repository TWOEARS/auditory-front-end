classdef icProc < Processor
%ICPROC Interaural Coherence processor.
%   The Interaural Coherence is estimated by determining the maximum value
%   of the normalized Cross-Correlation Function, which can be used to
%   select the time-frequency signal units whose binaural cues are
%   dominated by the direct sound for source localization [1].
%
%   See also: Processor, crosscorrelationProc
%
%   Reference:
%   [1] Faller, C. and Merimaa, J. (2004), "Source localization in complex 
%       listening situations: Selection of binaural cues based on interaural 
%       coherence," Journal of the Acoustical Society of America 116(5), 
%       pp. 3075?3089.
    
    properties
        % No additional properties for this processor
    end
    
    methods
        
        function pObj = icProc(fs,p)
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
            end
            if isempty(fs)
                error('Sampling frequency needs to be provided')
            end
            
            % Populate properties
            pObj.populateProperties('Type','Interaural correlation extractor',...
                'FsHzIn',fs,'FsHzOut',fs);
                
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
            
            % Loop over the time frame
            for ii = 1:nFrames
                
                % Loop over the frequency channel
                for jj = 1:nChannels
                    
                    % Find the peak in the discretized crosscorrelation
                    [c,i] = max(in(ii,jj,:));
                    
                    if i>1 && i<nLags
                        % Then interpolate using neighbor points
                        c_l = in(ii,jj,i-1);    % Lower neighbor
                        c_u = in(ii,jj,i+1);    % Upper neighbor
                        
                        delta = 0.5*(c_l-c_u)/(c_l-2*c+c_u);
                        
                        % Estimate "true" peak height through parabolic
                        % interpolation
                        out(ii,jj) = c-0.25*(c_l-c_u)*delta;
                        
                    else
                        % Do not interpolate if the peak is at a boundary
                        out(ii,jj)=c;
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