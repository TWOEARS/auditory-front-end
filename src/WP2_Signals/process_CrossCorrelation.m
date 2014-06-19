function [SIGNAL,SET] = process_CrossCorrelation(INPUT,SIGNAL)
%process_CrossCorrelation   Compute cross-correlation function.
%
%USAGE
%   [SIGNAL,SET] = process_CrossCorrelation(INPUT,SIGNAL)
%
%INPUT PARAMETERS
%          INPUT : haircell domain signal structure 
%         SIGNAL : signal structure initialized by init_WP2
% 
%OUTPUT PARAMETERS
%         SIGNAL : modified signal structure
%            SET : updated signal settings (e.g., filter states)

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
    data = resample(data,SIGNAL.fsHz,fsHz);
    fsHz = SET.fsHz;
end


%% INITIALIZE FRAME-BASED PROCESSING
% 
% 
% Compute framing parameters
wSize = 2 * round(SET.wSizeSec * fsHz / 2);
hSize = 2 * round(SET.hSizeSec * fsHz / 2);
win   = window(SET.winType,wSize);

% Determine size of input
[nSamples,nFilter,nChannels] = size(data);

% Check if input is binaural
if nChannels ~= 2
   error('Binaural input is required.') 
end

% Compute number of frames
nFrames = max(floor((nSamples-(wSize-hSize))/hSize),1);



%% BINAURAL CROSS-CORRELATION PROCESSING
% 
% 
% Determine maximum lag
maxLag = ceil(SET.maxDelaySec * fsHz);

% Allocate memory
output = zeros(maxLag * 2 + 1,nFrames,nFilter);

% Loop over number of auditory filters
for ii = 1 : nFilter
    
    % Framing
    frames_L = frameData(data(:,ii,1),wSize,hSize,win,false);
    frames_R = frameData(data(:,ii,2),wSize,hSize,win,false);
    
    % Cross-correlation analysis
    output(:,:,ii) = calcXCorr(frames_L,frames_R,maxLag,'coeff');
end


%% UPDATE SIGNAL STRUCTURE
% 
% 
% Copy signal
SIGNAL.data = output;