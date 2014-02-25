function [xcorr,STATES] = CrossCorrelationProcessing(periphery,STATES)
%
%USAGE
%       xcorr = CrossCorrelationProcessing(periphery,SIGNAL)
%
%INPUT PARAMETERS
%   periphery : Peripheral auditory signals
%      SIGNAL : signal parameter structures (initialized by init_WP2.m)
% 
%OUTPUT PARAMETERS
%        xcorr : cross-correlation pattern [nLags x nFilter x 2]

%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/22
%   v.0.2   2014/02/24 added STATES to output (for block-based processing)
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
[nSamples,nFilter,nChannels] = size(periphery); %#ok

% Short-cut
wSize = STATES.signals.framing.winSize;
hSize = STATES.signals.framing.hopSize;
win   = STATES.signals.framing.window;

% Compute number of frames
nFrames = max(floor((nSamples-(wSize-hSize))/(hSize)),1);


%% BINAURAL CROSS-CORRELATION PROCESSING
% 
% 
% Allocate memory
xcorr = zeros(STATES.signals.xcorr.maxLag*2+1,nFrames,nFilter);

% Loop over number of auditory filters
for ii = 1 : nFilter
    
    % Framing
    frames_L = frameData(periphery(:,ii,1),wSize,hSize,win,false);
    frames_R = frameData(periphery(:,ii,2),wSize,hSize,win,false);
    
    % Cross-correlation analysis
    % xcorr(:,:,ii) = xcorrNorm(frames_L,frames_R,STATES.binaural.maxLag);
    xcorr(:,:,ii) = calcXCorr(frames_L,frames_R,STATES.signals.xcorr.maxLag,'coeff');
end

