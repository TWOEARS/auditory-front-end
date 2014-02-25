function out = calcRMS(earSignals, P)
%calcRMS    Frame-based root mean squared value in dB.

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


%% INITIATE TIME FRAMING
% 
% 
% Determine size of input
[nSamples,nChannels] = size(earSignals); %#ok

% Compute number of frames
nFrames = max(floor((nSamples-(P.set.wSize-P.set.hSize))/(P.set.hSize)),1);

% Allocate memory
out = zeros(nFrames,2);


%% COMPUTE FRAME-BASED RMS 
% 
% 
% Compute frame-based RMS
out(:,1) = rms(frameData(earSignals(:,1),P.set.wSize,P.set.hSize,P.set.win,false),1);
out(:,2) = rms(frameData(earSignals(:,2),P.set.wSize,P.set.hSize,P.set.win,false),1);

% Scale RMS in dB
out = 10 * log10(out);
