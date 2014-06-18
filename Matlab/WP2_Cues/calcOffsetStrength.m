function [CUE,SET] = calcOffsetStrength(SIGNAL,CUE)
%calcOffsetStrength   Calculate offset strength in dB. 
% 
%USAGE
%   [CUE,SET] = calcOffsetStrength(SIGNAL,CUE)
%
%INPUT PARAMETERS
%      SIGNAL : signal structure
%         CUE : cue structure initialized by init_WP2
% 
%OUTPUT PARAMETERS
%         CUE : updated cue structure
%         SET : updated cue settings (e.g., filter states)

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
% Input signal 
data = SIGNAL.data;
fsHz = SIGNAL.set.fsHz;


%% GET CUE-RELATED SETINGS 
% 
% 
% Copy settings
SET = CUE.set;


%% DOWNMIX
% 
% 
if ~SET.bBinaural
    % Monoaural signals
    data = mean(data, 3);
end


%% SMOOTH ENVELOPE
% 
% 
% Perform leaky integration 
if exist('SET.states','var')
    [data,SET.states] = leakyIntegrator(data,fsHz,SET.decaySec,SET.states);
else
    [data,SET.states] = leakyIntegrator(data,fsHz,SET.decaySec);
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

% Compute number of frames
nFrames = max(floor((nSamples-(wSize-hSize))/hSize),1);


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
        frames = frameData(data(:,ii,jj),wSize,hSize,win,false);
                
        % Compute envelope energy in dB
        energy(ii,:,jj) = 10 * log10(sum(frames.^2,1));
    end
end


%% COMPUTE OFFSET STRENGTH
% 
% 
% Compute first order difference, zero-pad offset map
offset = cat(2,zeros(nFilter,1,nChannels),diff(energy,1,2));

% Discard onsets and limit offset strength
offset = min(abs(min(offset,0)),abs(SET.maxOffsetdB));


%% UPDATE CUE STRUCTURE
% 
% 
% Copy cue
CUE.data = offset;
