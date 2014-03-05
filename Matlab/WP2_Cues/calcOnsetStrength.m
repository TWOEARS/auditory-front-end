function [cues,SET] = calcOnsetStrength(signal,SET)
% 
%USAGE
%    [cues,SET] = calcOnsetStrength(signal,SET)
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


%% DOWNMIX
% 
% 
if ~SET.bBinaural
    % Monoaural signals
    signal = mean(signal, 3);
end


%% SMOOTH ENVELOPE
% 
% 
% Filter decay
intDecay = exp(-(1/(SET.fsHz * SET.decaySec)));

% Integration gain
intGain = 1-intDecay;

% Apply integration filter
signal = filter(intGain, [1 -intDecay], signal);


%% INITIATE FRAMING
% 
% 
% Determine input size
[nSamples,nFilter,nChannels] = size(signal);

% Compute number of frames
nFrames = max(floor((nSamples-(SET.wSize-SET.hSize))/SET.hSize),1);


%% COMPUTE ENERGY
% 
% 
% Allocate memory
energy = zeros(nFilter,nFrames,nChannels);

% Loop over number of auditory filters
for ii = 1 : nFilter
    
    % Loop over number of channels
    for jj = 1 : nChannels
        
        % Framing
        frames = frameData(signal(:,ii,jj),SET.wSize,SET.hSize,SET.win,false);
                
        % Compute envelope energy in dB
        energy(ii,:,jj) = 10 * log10(sum(frames.^2,1));
    end
end


%% COMPUTE ONSET STRENGTH
% 
% 
% Compute first order difference, zero-pad onset map
cues = cat(2,zeros(nFilter,1,nChannels),diff(energy,1,2));

% Discard offsets and limit onset strength
cues = min(max(cues,0),SET.maxOnsetdB);

