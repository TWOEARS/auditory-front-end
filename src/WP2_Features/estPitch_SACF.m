function [FEAT,SET] = estPitch_SACF(FEATURE,FEAT)

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/03/05
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% GET FEATURE-RELATED SETINGS 
% 
% 
% Copy settings
SET = FEAT.set;


%% RESTRICT LAG RANGE
% 
% 
% Maximun lag
[nLags,nFrames,nChannels] = size(FEATURE.data);

% Full lag vector
lags = 1:nLags;

% Restrict lags to plausible pitch range
rangeLags = round(FEATURE.set.fsHz./SET.fRangeHz);

% Find corresponding lags
bUseLags = lags >= min(rangeLags) & lags <= min(max(rangeLags),nLags);

% Restrict lags to predefined pitch range
sacf = FEATURE.data(bUseLags,:,:);
lags = lags(bUseLags);


%% DETECT PITCH CANDIDATES
% 
% 
% Allocate memory
pitch = zeros(nFrames,nChannels);
conf  = zeros(nFrames,nChannels);


% Loop over number of channels
for ii = 1 : nChannels
    
    % Data from ii-th channel
    iiSACF = sacf(:,:,ii);
    
    % Find all local peaks 
    [idxPeaks,I,J] = findLocalPeaks(iiSACF,'peaks',true); %#ok
       
    % Loop over number of frames
    for jj = 1 : nFrames
       
        % Get all local peaks
        iiPeaks = I(J==jj);
        
        % Find maximum peak position and confidence value
        [maxVal,maxIdx] = max(iiSACF(iiPeaks,jj));
        
        % Confidence value
        conf(jj,ii) = maxVal;
        
        % Only accept pitch estimate if confidence value is above 0
        if maxVal > 0
            % Pitch estimate in Hertz
            pitch(jj,ii) = FEATURE.set.fsHz/lags(iiPeaks(maxIdx));
        end
    end
end


%% POST-PROCESSING
% 
% 
% Floor confidence value
conf = max(conf,0);

% Compute threshold
confThres = max(conf,[],1) * SET.confThres;

% Apply threshold
[Izero,Jzero] = find(conf < repmat(confThres,[nFrames 1]));
% [Izero,Jzero] = find(conf < repmat(SET.confThres,[nFrames nChannels]));

% Set unreliable pitch estimates to zero
pitch(Izero,Jzero) = 0;


%% POST-PROCESSING
% 
% 
% Apply median filtering to reduce octave errors
pitch = medfilt1(pitch,SET.medFilt);
conf  = medfilt1(conf,SET.medFilt);

% Combine both measure
FEAT.data = cat(3,pitch,conf);