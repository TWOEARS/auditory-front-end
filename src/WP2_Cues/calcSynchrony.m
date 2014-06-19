function [CUE,SET] = calcSynchrony(SIGNAL,CUE)
%calcSynchrony   Compute across-channel synchrony. 
%
%USAGE
%    [CUE, SET] = calcITD(SIGNAL,CUE)
%
%INPUT ARGUMENTS
%      SIGNAL : signal structure
%         CUE : cue structure initialized by init_WP2
% 
%OUTPUT ARGUMENTS
%         CUE : updated cue structure
%         SET : updated cue settings (e.g., filter states)

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/03/05
%   ***********************************************************************


%% GET INPUT DATA
% 
% 
% Input signal and sampling frequency
acf  = SIGNAL.data;
fsHz = SIGNAL.fsHz;


%% GET CUE-RELATED SETINGS 
% 
% 
% Copy settings
SET = CUE.set;


%% RESTRICT LAG RANGE
% 
% 
% Maximun lag
maxLag = (size(acf,1)-1)/2;

% Full lag vector
lags = -maxLag:maxLag;

% Restrict lags to plausible pitch range
rangeLags = round(fsHz./SET.fRangeHz);

% Find corresponding lags
bUseLags = lags >= min(rangeLags) & lags <= min(max(rangeLags),maxLag);

% Restrict ACF pattern
acf = acf(bUseLags,:,:,:);

% Determine input size
[nLags,nFrames,nFilter,nChannels] = size(acf);


%% NORMALIZE AGC-PATTERN 
% 
% 
% Normalize data
acf = reshape(acf,[nLags nFrames * nFilter * nChannels]);

% Normalize auto-correlation pattern to have zero mean and unit variance 
acf = normalizeData(acf,'meanvar');

% Re-arrange normalized agc pattern
acf = reshape(acf,[nLags nFrames nFilter nChannels]);


%% COMPUTE SYNCHRONY
% 
% 
% Allocate memory
sync = zeros(nFilter,nFrames,nChannels);

% Loop over number of auditory filters
for ii = 1:nFilter-1
    
    % Compute correlation of normalized AGC across channels
    sync(ii,:,:) = mean(acf(:,:,ii,:) .* acf(:,:,ii+1,:),1);
end

% Copy last channel
sync(nFilter,:,:) = sync(nFilter-1,:,:);


%% UPDATE CUE STRUCTURE
% 
% 
% Copy cue
CUE.data = sync;