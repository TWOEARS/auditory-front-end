classdef pitchProc < Processor
    
    properties
        pitchRangeHz    % Range in Hz for valid pitch estimation
        confThresPerc   % Threshold for pitch condidence measure (re. 1)
        orderMedFilt    % Median order filter for pitch smoothing
        lags            % Vector of auto-correlation lags
    end
    
    properties (Access = protected)
        bValidLags      % Which lags are in the pitch range
        pitchBuffer     % Buffer for online Median filtering
    end
    
    
    methods
        function pObj = pitchProc(fs,lags,p)
            %pitchProc    Constructs an pitch estimation processor
            %
            %USAGE
            %  pObj = pitchProc(fs)
            %  pObj = pitchProc(fs,p)
            %
            %INPUT PARAMETERS
            %    fs : Sampling frequency (Hz)
            %     p : Structure of non-default parameters
            %
            %OUTPUT PARAMETERS
            %  pObj : Processor Object
            
            if nargin > 0
                
            % Checking input parameters
            if isempty(fs)
                error('Sampling frequency needs to be provided')
            end
            if nargin<3||isempty(p)
                p = getDefaultParameters(fs,'processing');
            else
                p = parseParameters(p);
            end
                
            if mod(p.medianOrder,1)~=0
                p.medianOrder = round(p,medianOrder);
                warning('Median filter order should be an integer, using %i instead',p.medianOrder)
            end
            
            % Populate properties
            pObj.pitchRangeHz = p.pi_rangeHz;
            pObj.confThresPerc = p.pi_confThres;
            pObj.orderMedFilt = p.pi_medianOrder;
            pObj.lags = lags;
            
            
                
            pObj.Type = 'Pitch estimator';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;
                
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
            
            
            % Compute summary ACF
            sacf = squeeze(mean(in,2));
            
            % Input size
            [nFrames,nLags] = size(sacf);

            % Restrict lags to plausible pitch range (only for first call?)
            rangeLagSec = 1./pObj.pitchRangeHz;
            pObj.bValidLags = (pObj.lags >= min(rangeLagSec)) & ...
                (pObj.lags <= min(max(rangeLagSec),nLags));
            
            % Restrict lags to predefined pitch range
            sacf = sacf(:,pObj.bValidLags);
            lagsSec = pObj.lags(pObj.bValidLags);
            
            %% DETECT PITCH CANDIDATES
            % 
            % 
            % Allocate memory
            pitchHzRaw = zeros(nFrames,1);
            confidence = zeros(nFrames,1);

            % Loop over number of frames
            for ii = 1 : nFrames

                % Detect local peaks
                [peakIdx,peakVal] = findpeaks_VB(sacf(ii,:));

                % Find maximum peak position and confidence value
                [maxVal,maxIdx] = max(peakVal);

                % Confidence value
                if isempty(maxVal)
                    maxVal = 0;
                else
                    confidence(ii) = maxVal;
                end

                % Only accept pitch estimate if confidence value is above 0
                if maxVal > 0
                    % Pitch estimate in Hertz
                    pitchHzRaw(ii) = 1/lagsSec(peakIdx(maxIdx));
                end
            end
            
            %% POST-PROCESSING
            % 
            % 
            % Floor confidence value
            confidence = max(confidence,0);

            % Compute threshold
            pObj.confThresPerc = max(confidence,[],1) * pObj.confThresPerc;

            % Apply confidence threshold
            bSetToZero = confidence < repmat(pObj.confThresPerc,[nFrames 1]);

            % Set unreliable pitch estimates to zero
            pitchHz = pitchHzRaw; pitchHz(bSetToZero) = 0;
            
            %% POST-PROCESSING
            % 
            % 
            % Apply median filtering to reduce octave errors
            % We have to fiddle a bit with online compatibility...
            % For a filter of order N,
            %   - Last (N-1)/2 (N odd) or N/2-1 (N even) sample cannot be obtained
            %   - Corresponding ones from the previous chunk can now be obtained
            
            % Append buffer
            pitchHzBuf = [pObj.pitchBuffer ; pitchHz];
            
            pitchHzFilt = medfilt1(pitchHzBuf,pObj.orderMedFilt);
            
            % Discard 

            % Replace all zeros with NANs
            pitchHz(pitchHz==0) = NaN;
            
        end
        
        
    end
    
end