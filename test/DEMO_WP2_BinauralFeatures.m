%Test_WP2_Framework 
% 

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/03/31
%   ***********************************************************************

clear
close all
clc

% Add working directories to path
addpath ../src/Tools
addpath ../src/AuditoryModel
addpath ../src/HRTF_WP1

addpath ../src/WP2_Framework
addpath ../src/WP2_Signals
addpath ../src/WP2_Cues
addpath ../src/WP2_Features
addpath ../src/WP2_Data


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
        SET.nErbs      = 1;          % ERB spacing of gammatone filters
        SET.fLowHz     = 80;         % Lowest center frequency in Hertz
        SET.fHighHz    = 8E3;        % Highest center frequency in Hertz
        SET.bAlign     = false;      % Time-align auditory channels
        SET.ihcMethod  = 'halfwave';
        
        % Binaural cross-correlation processor
        SET.maxDelaySec = 1.1E-3;
        
        % Framing parameters
        SET.winSizeSec = 20E-3;     % Window size in seconds
        SET.hopSizeSec = 10E-3;     % Window step size in seconds
        SET.winType    = 'hann';    % Window type
        
        % Specify cues that should be extracted
        strCues = {'itd_xcorr' 'ic_xcorr' 'ild'};
        
        % Specify features that should be extracted :
        strFeatures = {};

    otherwise
        error('Preset is not supported');
end



%% LOAD ACOUSTIC SIGNAL
% 
% 
% Load 'earSignals' and 'fsHz'
load('TestBinauralCues');


%% INITIALIZE WP2 PROCESSING
% 
% 
% Initialize all WP2-related parameters
STATES = init_WP2(strFeatures,strCues,SET);


%% PERFORM WP2 PROCESSING
% 
% 
% Perform WP2 computation
[SIGNALS,CUES,FEATURES,STATES] = process_WP2(earSignals,fsHz,STATES);

    
%% PLOT EXTRACTED CUES
% 
% 
for ii = 1 : length(CUES)
    figure;
    imagesc(CUES(ii).data)
    title(CUES(ii).name)
end
