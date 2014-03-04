%Test_WP2_Framework 
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
        % *****************************************************************
        % 'rms' 'ratemap' 'itd_xcorr' 'ic_xcorr' 'ild'
        % *****************************************************************
        strCues = {};
        
        % Specify features that should be extracted :
        % *****************************************************************
        % 'ratemap_feature' 'azimuth' 'azimuth_hist' 'source_position'         
        % *****************************************************************
        strFeatures = {'ratemap_feature' 'source_position'};
        
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


%% EVALUATION SETTINGS
% 
% 
% Number of acoustic mixtures for each acoustic condition
nMixtures = 10; 

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
azRange = (-90:1:90)';

% Audio path
pathAudio = [pwd,filesep,'Audio',filesep];

% Scan for audio files
audioFiles = listFiles(pathAudio,'*.wav');

% Number of different conditions
nSentences = numel(audioFiles);
nAzim      = numel(azRange);

% Allocate memory
[pc,rmse] = deal(zeros(nMixtures,1));

% Matrix with randomized sound source positions
azPos = azRange(round(1+(nAzim-1) * rand(nMixtures,nSpeakers)));


%% INITIALIZE WP2 PROCESSING
% 
% 
% Initialize all WP2-related parameters
STATES = init_WP2(strFeatures,strCues,SET);


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
    audio = readAudio(files,fsHz);
    
    % Spatialize audio signals using HRTF processing
    earSignals = auralizeWP1(audio,fsHz,azPos(ii,:));
    
    % Perform WP2 computation
    [SIGNALS,CUES,FEATURES,STATES] = process_WP2(earSignals,fsHz,STATES);
    
    % Select most salient source positions
    azEst = FEATURES(strcmp([FEATURES(:).name],'source_position')).data(1:nSpeakers,:);
  
    % Evaluate localization performance (e.g. in WP6)
    [pc(ii),rmse(ii)] = evalPerformance(azPos(ii,:),azEst,thresDeg);
    
    % Report progress
    fprintf('\nLocalization experiment: %.2f %%',100*ii/nMixtures);
end    
    
fprintf('\n\nLocalization accuracy\n');
fprintf('Percentage correct: %.2f %%\n%',mean(pc,1));
fprintf('RMSE: %.2f %',nanmean(rmse,1));

