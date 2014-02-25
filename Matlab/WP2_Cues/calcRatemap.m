function cues = calcRatemap(periphery,P)
% 
%USAGE
%    cues = calcRatemap(periphery,S)
%
%INPUT PARAMETERS
% 
%OUTPUT PARAMETERS
% 

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/21
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Determine input size
[nSamples,nFilter,nChannels] = size(periphery);

% Short-cut
wSize = P.set.wSize;
hSize = P.set.hSize;
win   = window(P.set.winType,wSize);

% Compute number of frames
nFrames = max(floor((nSamples-(wSize-hSize))/(hSize)),1);

 % Allocate memory
cues = zeros(nFilter,nFrames,nChannels);


%% COMPUTE RATEMAP
% 
% 
% Filter deacy
intDecay = exp(-(1/(P.set.fsHz * P.set.decaySec)));

% Integration gain
intGain = 1-intDecay;

% Apply integration filter
periphery = filter(intGain, [1 -intDecay], periphery);
 
% Loop over number of auditory channels
for ii = 1 : nFilter
    
    % Framing
    frames_L = frameData(periphery(:,ii,1),wSize,hSize,win,false);
    frames_R = frameData(periphery(:,ii,2),wSize,hSize,win,false);
    
    % Frame-based averaging 
    cues(ii,:,1) = mean(frames_L,1);
    cues(ii,:,2) = mean(frames_R,1);
end

