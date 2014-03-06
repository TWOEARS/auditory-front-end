function [output,SET] = process_AutoCorrelation(signal,SET)
%
%USAGE
%       xcorr = process_AutoCorrelation(periphery,SIGNAL)
%
%INPUT PARAMETERS
%   periphery : Peripheral auditory signals
%      SIGNAL : signal parameter structures (initialized by init_WP2.m)
% 
%OUTPUT PARAMETERS
%        xcorr : auto-correlation pattern [nLags x nFilter x 2]

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


%% INITIATE TIME FRAMING
% 
% 
% Determine size of input
[nSamples,nFilter,nChannels] = size(signal);

% Compute number of frames
nFrames = max(floor((nSamples-(SET.wSize-SET.hSize))/(SET.hSize)),1);

% Maximum lag
maxLag = SET.wSize - 1;


%% PRE-PROCESSING
%
%
% Pre-processing input signal
if SET.bBandpass
    % Design second-order bandpass
    [bBP,aBP] = butter(2,[450 8500]/(SET.fsHz/2));
    
    % Apply filter
    signal = filter(bBP,aBP,signal);
end


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
        frames = frameData(signal(:,ii,jj),SET.wSize,SET.hSize,SET.win,false);
            
        % Perform center clipping
        if SET.bCenterClip
            frames = applyCenterClipping(frames,SET.ccMethod,SET.ccAlpha);
        end
 
        % Auto-correlation analysis
        acf = calcACorr(frames,[],'coeff');
        
        % Store ACF pattern for positive lags only
        output(:,:,ii,jj) = acf(maxLag+1:end,:);
    end
end

