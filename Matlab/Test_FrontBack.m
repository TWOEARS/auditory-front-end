clear
close all
clc

% Add working directories to path
addpath Tools
addpath AuditoryModel
addpath HRTF_WP1

addpath WP2_Framework
addpath WP2_Signals
addpath WP2_Cues
addpath WP2_Features


%% ALGORITHM SETTINGS
% 
% 
% Basic feature set
preset = 'basic';

% Reference sampling frequency in Hertz
fsHz = 44.1E3;

% Change preset-specific parameters
switch(lower(preset))
    case 'basic'
        
        % Input signal
        SET.fsHz       = fsHz;
        SET.bNormRMS   = false;
        
        % Auditory periphery
        SET.nErbs      = 1;         % ERB spacing of gammatone filters
        SET.fLowHz     = 50;        % Lowest center frequency in Hertz
        SET.fHighHz    = 10E3;      % Highest center frequency in Hertz
        SET.bAlign     = false;     % Time-align auditory channels
        SET.ihcMethod  = 'halfwave';
        
        % Binaural cross-correlation processor
        SET.maxDelaySec = 1.1E-3;
        
        % Framing parameters
        SET.winSizeSec = 20E-3;     % Window size in seconds
        SET.hopSizeSec = 10E-3;     % Window step size in seconds
        SET.winType    = 'hann';    % Window type
        
        % Specify cues that should be extracted
%         strCues = {'ild'};
        strCues = {'ild' 'average_deviation'};
        strFeatures = {};
    otherwise
        error('Preset is not supported');
end



%% ACOUSTIC SETTINGS
% 
% 
% Define number of competing speech sources
nSpeakers = 1;

% Number of acoustic mixtures for each acoustic condition
nMixtures = 20; 


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

% Audio path
pathAudio = [pwd,filesep,'Audio',filesep];

% Scan for audio files
audioFiles = listFiles(pathAudio,'*.wav');

% Number of different conditions
nSentences = numel(audioFiles);


%% INITIALIZE WP2 PROCESSING
% 
STATES = init_WP2(strFeatures,strCues,SET);


%% MAIN LOOP OF THE LOCALIZATION EXPERIMENT
%
%
% Loop over number of acoustic mixtures
for ii = 1 : nMixtures
    
    % Randomly select "nSpeakers" sentences
    files = {audioFiles(round(1+(nSentences-1) * rand(nSpeakers,1))).name};
    
    % Read audio signals
    audio = readAudio(files,fsHz);
    
    % Spatialize audio signals using HRTF processing
    earSignals1 = auralizeWP1(audio,fsHz,0);
    earSignals2 = auralizeWP1(audio,fsHz,180);
        
    % Perform WP2 computation
    [SIGNALS1,CUES1,FEATURES1,STATES1] = process_WP2(earSignals1,fsHz,STATES);
    [SIGNALS2,CUES2,FEATURES2,STATES2] = process_WP2(earSignals2,fsHz,STATES);
    
    % Report progress
    fprintf('\nLocalization experiment: %.2f %%',100*ii/nMixtures);
end    
    
fprintf('\n\nLocalization accuracy\n');
fprintf('Percentage correct: %.2f %%\n%',mean(pc,1));
fprintf('RMSE: %.2f %',nanmean(rmse,1));

