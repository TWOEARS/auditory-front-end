function [sync,SET] = calcSynchrony(acf,SET)
%calcSynchrony   Compute across-channel synchrony. 
%
%USAGE
%    sync = calcITD(acf,P)
%
%INPUT ARGUMENTS
%    acf : auto-correlation pattern [nLags x nFrames x nFilter x [left right]]
%      P : parameter structure
% 
%OUTPUT ARGUMENTS
%   sync : across-channel synchrony [nFilter x nFrames x [left right]]

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


%% RESTRICT LAG RANGE
% 
% 
% Maximun lag
maxLag = (size(acf,1)-1)/2;

% Full lag vector
lags = -maxLag:maxLag;

% Restrict lags to plausible pitch range
rangeLags = round(SET.fsHz./SET.fRangeHz);

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