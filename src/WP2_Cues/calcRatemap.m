function [CUE,SET] = calcRatemap(SIGNAL,CUE)
%calcRatemap   Calculate ratemap representation. 
% 
%USAGE
%   [CUE,SET] = calcRatemap(SIGNAL,CUE)
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
    data = mean(data, 3);
end


%% INITIALIZE FRAME-BASED PROCESSING
% 
% 
% Compute framing parameters
wSize = 2 * round(SET.wSizeSec * fsHz / 2);
hSize = round(SET.hSizeSec * fsHz);
win   = window(SET.winType,wSize);

% Determine size of input
[nSamples,nFilter,nChannels] = size(data);

% Compute number of frames
nFrames = max(floor((nSamples-(wSize-hSize))/hSize),1);

 % Allocate memory
ratemap = zeros(nFilter,nFrames,nChannels);


%% COMPUTE RATEMAP
% 
% 
% Perform leaky integration 
if exist('SET.states','var')
    [data,SET.states] = leakyIntegrator(data,fsHz,SET.decaySec,SET.states);
else
    [data,SET.states] = leakyIntegrator(data,fsHz,SET.decaySec);
end

% Loop over number of auditory channels
for ii = 1 : nFilter
    
    % Loop over number of channels
    for jj = 1 : nChannels
        
        % Select method for downsampling
        switch(lower(SET.scaling))
            case 'magnitude'
                if SET.bDownSample
                    % Downsample input
                    ratemap(ii,:,jj) = data(wSize:hSize:nSamples,ii,jj);
                else
                    % Framing
                    frames = frameData(data(:,ii,jj),wSize,hSize,win,false);
                    
                    % Frame-based averaging
                    ratemap(ii,:,jj) = mean(frames,1);
                end
            case 'power'
                if SET.bDownSample
                    % Downsample input
                    ratemap(ii,:,jj) = data(wSize:hSize:nSamples,ii,jj).^2;
                else
                    % Framing
                    frames = frameData(data(:,ii,jj),wSize,hSize,win,false);
                    
                    % Frame-based averaging
                    ratemap(ii,:,jj) = mean(frames.^2,1);
                end
            otherwise
                error('Ratemap scaling ''%s'' is not supprted',lower(SET.scaling));
        end
    end
end


%% UPDATE CUE STRUCTURE
% 
% 
% Copy cue
CUE.data = ratemap;
