classdef pitchProc < Processor
%PITCHPROC Pitch processor.
%   Based on the Summary Auto-Correlation Function representation, this processor
%   detects the most salient peak within the given plausible pitch frequency range 
%   for each time frame in order to obtain an estimation of the fundamental 
%   frequency.
%
%   PITCHPROC properties:
%        pitchRangeHz    - Range in Hz for valid pitch estimation
%        confThresPerc   - Threshold for pitch condidence measure (re. 1)
%        orderMedFilt    - Median order filter for pitch smoothing
%        lags            - Vector of auto-correlation lags
%
%   See also: Processor, autocorrelationProc

    properties (SetAccess = protected)
        pitchRangeHz    % Range in Hz for valid pitch estimation
        confThresPerc   % Threshold for pitch condidence measure (re. 1)
        orderMedFilt    % Median order filter for pitch smoothing
        lags            % Vector of auto-correlation lags
    end
    
    properties (Access = protected)
        bValidLags      % Which lags are in the pitch range
        pitchBuffer     % Buffer for online Median filtering
        maxConf         % Buffer interface for maximum confidence
        maxConfBuf      % Circular buffer for maximum confidence
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
                
            if mod(p.pi_medianOrder,1)~=0
                p.pi_medianOrder = round(p.pi_medianOrder);
                warning('Median filter order should be an integer, using %i instead',p.pi_medianOrder)
            end
            
            % Populate properties
            pObj.pitchRangeHz = p.pi_rangeHz;
            pObj.confThresPerc = p.pi_confThres;
            pObj.orderMedFilt = p.pi_medianOrder;
            pObj.lags = lags;
            
            bufferDurSec = 5;   % Maximum confidence is taken in the past 5 seconds
            pObj.maxConfBuf = circVBuf(bufferDurSec*fs,1);
            pObj.maxConf = circVBufArrayInterface(pObj.maxConfBuf);
                
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
                    pObj.maxConfBuf.append(max(maxVal,0));
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
%             pObj.confThresPerc = max(confidence,[],1) * pObj.confThresPerc;
            confThresPerc = max(pObj.maxConf(:)) * pObj.confThresPerc;

            % Apply confidence threshold
            bSetToZero = confidence < repmat(confThresPerc,[nFrames 1]);

            % Set unreliable pitch estimates to zero
            pitchHz = pitchHzRaw; pitchHz(bSetToZero) = 0;
            
            % Apply median filtering to reduce octave errors
            Npre = floor(pObj.orderMedFilt/2);      % Past samples considered in median
            Npost = ceil(pObj.orderMedFilt/2)-1;    % Future samples considered in median
            
            % We have to fiddle a bit with online compatibility...
            % For a filter of order N,
            %   - Last (N-1)/2 (N odd) or N/2-1 (N even) sample cannot be obtained
            %   - Corresponding ones from the previous chunk can now be obtained
            
            % Append buffer
%             pitchHzBuf = [pObj.pitchBuffer ; pitchHz];
            
%             pitchHzFilt = medfilt1(pitchHzBuf,pObj.orderMedFilt);
            filtPitch = medfilt1(pitchHz,pObj.orderMedFilt);
            
            % Discard the last Npost samples (accurate median estimation would need next 
            % input chunk) and the first Npre samples (used only to compute
            % Npre+1:Npre+Npost samples)
%             filtPitch = pitchHzFilt(Npre+1:end-Npost);

            % NB: The above statement leads to a pitch estimate which is shifted in time
            % by Npost samples. Could we correct for that?
            
            % Update buffer: the last Npost samples that were discarded need to be
            % computed at next chunk, so we need Npost+Npre extra samples in the buffer
%             pObj.pitchBuffer = pitchHzBuf(end-Npost-Npre:end);
            
            % Replace all zeros with NANs
            filtPitch(filtPitch==0) = NaN;
            
            % TODO: Solve the following
%             filtPitch = [NaN;filtPitch;NaN];
            
            % Generate the output
            out = [filtPitch pitchHzRaw confidence];
%             out = filtPitch;
%             out = pitchHzFilt;
%             out = bSetToZero;
%             out = pitchHzRaw;
%             out = confidence;
            
        end
        
        function reset(pObj)
            pObj.pitchBuffer = [];
        end
        
        function hp = hasParameters(pObj,p)
            hp = 1;
        end
        
    end
    
end