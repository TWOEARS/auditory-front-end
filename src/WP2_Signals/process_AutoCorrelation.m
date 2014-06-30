function [SIGNAL,SET] = process_AutoCorrelation(INPUT,SIGNAL)
%process_AutoCorrelation   Compute auto-correlation function.
%
%USAGE
%   [SIGNAL,SET] = process_AutoCorrelation(INPUT,SIGNAL)
%
%INPUT PARAMETERS
%       INPUT : haircell domain signal structure 
%      SIGNAL : signal structure initialized by init_WP2
% 
%OUTPUT PARAMETERS
%      SIGNAL : updated signal structure
%         SET : updated signal settings (e.g., filter states)

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


%% GET INPUT DATA
% 
% 
% Input signal and sampling frequency
data = INPUT.data;
fsHz = INPUT.fsHz;


%% GET SIGNAL-RELATED SETINGS 
% 
% 
% Copy settings
SET = SIGNAL.set;


%% RESAMPLING
% 
% 
% Resample input signal, is required
if fsHz ~= SIGNAL.fsHz 
    data = resampleData(data,SIGNAL.fsHz,fsHz);
    fsHz = SIGNAL.fsHz;
end


%% INITIALIZE FRAME-BASED PROCESSING
% 
% 
% Compute framing parameters
wSize = 2 * round(SET.wSizeSec * fsHz / 2);
hSize = round(SET.hSizeSec * fsHz);
win   = window(SET.winType,wSize);

% Determine size of input
[nSamples,nFilter,nChannels] = size(data);

% Compute number of frames
nFrames = max(floor((nSamples-(wSize-hSize))/hSize),1);

% Maximum lag
maxLag = wSize - 1;


% % Pre-processing input signal
% if SET.bBandpass
%     % Design second-order bandpass
%     [bBP,aBP] = butter(2,[450 8500]/(fsHz/2));
%     
%     % Apply filter
%     signal = filter(bBP,aBP,signal);
% end


%% AUTO-CORRELATION PROCESSING
% 
% 
% Allocate memory
output = zeros(maxLag + 1,nFrames,nFilter,nChannels);

% Loop over number of auditory filters
for ii = 1 : nFilter
    % Loop over number of channels
    for jj = 1 : nChannels
        
        % Framing
        frames = frameData(data(:,ii,jj),wSize,hSize,win,false);
            
        % Perform center clipping
        if SET.bCenterClip
            frames = applyCenterClipping(frames,SET.ccMethod,SET.ccAlpha);
        end
 
        % Auto-correlation analysis
        acf = calcACorr(frames,[],'coeff',SET.K);
        
        % Store ACF pattern for positive lags only
        output(:,:,ii,jj) = acf(maxLag+1:end,:);
    end
end


%% UPDATE SIGNAL STRUCTURE
% 
% 
% Copy signal
SIGNAL.data = output;