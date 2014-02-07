%localization_experiment   ITD-based sound source localization 
% 

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2013
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/22
%   ***********************************************************************

clear
close all
clc

% Add working directories to path
addpath Tools
addpath AuditoryModel
addpath FeatureExtraction
addpath Framework


%% ALGORITHM SETTINGS
% 
% 

% Localization approach

% preset = 'broadband';   % No peripheral processing
preset = 'subband';   % With peripheral processing


% Reference sampling frequency in Hertz
fs = 48E3;

STATES.signal.fsHz     = fs;
STATES.signal.bNormRMS = false;

% Auditory periphery
STATES.periphery.bCompute = true;      % Activate auditory front-end
STATES.periphery.nErbs    = 1;         % Number of gammatone filters per ERB
STATES.periphery.fLowHz   = 100;       % Lowest center frequency in Hertz
STATES.periphery.fHighHz  = 8E3;       % Highest center frequency in Hertz
STATES.periphery.bAlign   = false;     % Time-align auditory channels 

% Binaural stage
STATES.binaural.BinProcType ='Xcorr';  % Type of binaural processing Xcorr or EC
STATES.binaural.winSizeSec  = 20E-3;   % Window size in seconds used for correlation analysis
STATES.binaural.maxDelaySec = 1E-3;    % Maximum time delay that is considered

% Cue selection
STATES.CueSelection = false;           % Cue-Selection mechanism

% Feature extraction
STATES.FeatureExtraction = true;       % Feature extraction

% Change preset-specific parameters
switch(lower(preset))
    case 'broadband'    
        % Deactivate auditory front-end
        STATES.periphery.bCompute = false;
    case 'subband'
        % Activate auditory front-end
        STATES.periphery.bCompute = true;
    otherwise
        error('Preset is not supported');
end


%% ACOUSTIC SETTINGS
% 
% 
% Define number of competing speech sources
nSpeakers = 2;

% Minimum distance between competing sound sources in degree
minDistance = 5;

% *************************************************************************
% List of different rooms:
% *************************************************************************
% 'SURREY_A' 'SURREY_ROOM_A' 'SURREY_ROOM_B' 'SURREY_ROOM_C' 'SURREY_ROOM_D'
%  
%  RT60 = 0s  RT60 = 0.32s    RT60 = 0.47s    RT60 = 0.68s   RT60 = 0.89s
%  DRR  = inf DRR  = 6.09dB   DRR  = 5.31dB   DRR  = 8.82dB  DRR  = 6.12dB
% 

% rooms = {'SURREY_A' 'SURREY_ROOM_A' 'SURREY_ROOM_B' 'SURREY_ROOM_C' 'SURREY_ROOM_D'};
rooms = {'SURREY_A'};


%% EVALUATION SETTINGS
% 
% 
% Number of acoustic mixtures for each acoustic condition
nMixtures = 5; 

% Absolute error boundary in degree
thresDeg = 10;

   

%% INITIALIZE PARAMETERS
%
%
% Reset internal states of random number generator. This allows to use
% different settings, while still obtaining the "same" random matrix with
% sound source positions.
try
    % Since MATLAB 2011a 
    rng(0);
catch
    % For older versions
    rand('seed',0); %#ok
end

% Azimuth range of sound source positions
azRange = (-90:5:90)';

% Audio path
pathAudio = [pwd,filesep,'Audio',filesep];

% Scan for audio files
audioFiles = listFiles(pathAudio,'*.wav');

% Number of different conditions
nRooms     = numel(rooms);
nSentences = numel(audioFiles);
nAzim      = numel(azRange);

% Allocate memory
[pc,rmse] = deal(zeros(nMixtures,nRooms));

% Matrix with randomized sound source positions
azPos = azRange(round(1+(nAzim-1) * rand(nMixtures,nSpeakers)));

%% INITIALIZE WP2 PROCESSING
% 
STATES = init_WP2(STATES);


%% MAIN LOOP OF THE LOCALIZATION EXPERIMENT
%
%
% Loop over number of acoustic mixtures
for ii = 1 : nMixtures
    
    % Randomly select "nSpeakers" sentences
    files = {audioFiles(round(1+(nSentences-1) * rand(nSpeakers,1))).name};
    
    % Enforce a "minDistance" spacing between all sources
    while any(diff(sort(azPos(ii,:),'ascend'),1,2) <= minDistance)
        % Revise random initialization
        azPos(ii,:) = azRange(round(1+(nAzim-1) * rand(1,nSpeakers)));
    end

    % Read audio signals
    audio = readAudio(files,fs);

    % Loop over number of different rooms
    for rr = 1 : nRooms
           
        % Spatialize audio signals using HRTF processing
        earSignals = spatializeAudio(audio,fs,azPos(ii,:),rooms{rr});
        
        % Perform WP2 computation
        [SIGNALS,FEATURES,STATES] = process_WP2(earSignals,STATES);
                
        % Select most salient azimuth directions (e.g. in WP3)
        azEst = selectAzimuth(FEATURES.azimuth.direction,FEATURES.azimuth.salience,nSpeakers);
                
        % Evaluate localization performance (e.g. in WP6)
        [pc(ii,rr),rmse(ii,rr)] = evalPerformance(azPos(ii,:),azEst,thresDeg);
    end
    
    % Report progress
    fprintf('\nLocalization experiment: %.2f %%',100*ii/nMixtures);
end    
    
fprintf('\n\nLocalization accuracy\n');
fprintf('Percentage correct: %.2f %%\n%',mean(pc,1));
fprintf('RMSE: %.2f %',nanmean(rmse,1));

