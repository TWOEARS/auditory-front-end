function [CUE, SET] = calcRMS(SIGNAL, CUE)
%calcRMS    Frame-based root mean squared value in dB.
%
%USAGE
%   [CUE,SET] = calcRMS(SIGNAL,CUE)
%
%INPUT ARGUMENTS
%      SIGNAL : signal structure
%         CUE : cue structure initialized by init_WP2
% 
%OUTPUT ARGUMENTS
%         CUE : updated cue structure
%         SET : updated cue settings (e.g., filter states)

%   Author  :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/22
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
data = SIGNAL.data;
fsHz = SIGNAL.fsHz;


%% GET CUE-RELATED SETINGS 
% 
% 
% Copy settings
SET = CUE.set;


%% DOWNMIX
% 
% 
if ~SET.bBinaural
    % Monoaural signal
    data = mean(data, 2);
end


%% INITIALIZE FRAME-BASED PROCESSING
% 
% 
% Compute framing parameters
wSize = 2 * round(SET.wSizeSec * fsHz / 2);
hSize = 2 * round(SET.hSizeSec * fsHz / 2);
win   = window(SET.winType,wSize);

% Determine size of input
[nSamples,nChannels] = size(data);

% Compute number of frames
nFrames = max(floor((nSamples-(wSize-hSize))/hSize),1);

% Allocate memory
out = zeros(nFrames,2);


%% COMPUTE FRAME-BASED RMS
%
%
% Loop over number of channels
for jj = 1 : nChannels
    
    % Segment signals into overlapping frames
    frames = frameData(data(:,jj),wSize,hSize,win,false);
    
    % Compute frame-based RMS
    out(:,jj) = rms(frames,1);
    
    % Scale RMS in dB
    out(:,jj) = 10 * log10(out(:,jj));
end


%% UPDATE CUE STRUCTURE
% 
% 
% Copy cue
CUE.data = out;
