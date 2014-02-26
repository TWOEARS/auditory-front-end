function [out,SET] = calcRMS(signal, SET)
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
[nSamples,nChannels] = size(signal); %#ok

% Compute number of frames
nFrames = max(floor((nSamples-(SET.wSize-SET.hSize))/SET.hSize),1);

% Allocate memory
out = zeros(nFrames,2);


%% COMPUTE FRAME-BASED RMS 
% 
% 
% Segment signals into overlapping frames
frameL = frameData(signal(:,1),SET.wSize,SET.hSize,SET.win,false);
frameR = frameData(signal(:,2),SET.wSize,SET.hSize,SET.win,false);

% Compute frame-based RMS
out(:,1) = rms(frameL,1);
out(:,2) = rms(frameR,1);

% Scale RMS in dB
out = 10 * log10(out);
