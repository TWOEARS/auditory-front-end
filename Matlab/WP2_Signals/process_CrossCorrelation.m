function [output,SET] = process_CrossCorrelation(signal,SET)
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
[nSamples,nFilter,nChannels] = size(signal); %#ok

% Compute number of frames
nFrames = max(floor((nSamples-(SET.wSize-SET.hSize))/(SET.hSize)),1);


%% BINAURAL CROSS-CORRELATION PROCESSING
% 
% 
% Allocate memory
output = zeros(SET.maxLag * 2 + 1,nFrames,nFilter);

% Loop over number of auditory filters
for ii = 1 : nFilter
    
    % Framing
    frames_L = frameData(signal(:,ii,1),SET.wSize,SET.hSize,SET.win,false);
    frames_R = frameData(signal(:,ii,2),SET.wSize,SET.hSize,SET.win,false);
    
    % Cross-correlation analysis
    % xcorr(:,:,ii) = xcorrNorm(frames_L,frames_R,STATES.binaural.maxLag);
    output(:,:,ii) = calcXCorr(frames_L,frames_R,SET.maxLag,'coeff');
end

