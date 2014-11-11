clear;
close all
clc


%% LOAD SIGNAL
% 
% 
% Load a signal
load('AFE_earSignals_16kHz');

% Create a data object based on the right ear signal
dObj = dataObject(earSignals(:,2),fsHz);


%% PLACE REQUEST AND CONTROL PARAMETERS
% 
% 
% Request amplitude modulation spectrogram (AMS) feaures
requests = {'ams_features'};

% Parameters of Gammatone processor
gt_nChannels  = 23;  
gt_lowFreqHz  = 80;
gt_highFreqHz = 8000;

% Parameters of AMS processor
ams_fbType_lin = 'lin';
ams_fbType_log = 'log';
ams_wSizeSec   = 32E-3;
ams_hSizeSec   = 16E-3;

% Parameters for linearly-scaled AMS
parLin = genParStruct('gt_lowFreqHz',gt_lowFreqHz,'gt_highFreqHz',gt_highFreqHz,...
                      'gt_nChannels',gt_nChannels,'ams_wSizeSec',ams_wSizeSec,...
                      'ams_hSizeSec',ams_hSizeSec,'ams_fbType',ams_fbType_lin); 
                  
% Parameters for logarithmically-scaled AMS                  
parLog = genParStruct('gt_lowFreqHz',gt_lowFreqHz,'gt_highFreqHz',gt_highFreqHz,...
                      'gt_nChannels',gt_nChannels,'ams_wSizeSec',ams_wSizeSec,...
                      'ams_hSizeSec',ams_hSizeSec,'ams_fbType',ams_fbType_log);                   

               
%% PERFORM PROCESSING
% 
% 
% Create a manager
mObj = manager(dObj,{requests requests},{parLin parLog});

% Request processing
mObj.processSignal();


%% PLOT RESULTS
% 
% 
% Plot time domain signal
dObj.time{1}.plot;grid on;ylim([-1 1]);title('Time domain signal')

% Envelope
env  = [dObj.innerhaircell{1}.Data(:,:)];
fHz  = dObj.gammatone{1}.cfHz;
tSec = (1:size(env,1))/fsHz;

figure;
waveplot(env(1:3:end,:),tSec(1:3:end),fHz);
title('IHC')

% Plot linear AMS pattern
dObj.ams_features{1}.plot;title('linear AMS features')

% Plot logarithmic AMS pattern
dObj.ams_features{2}.plot;title('logarithmic AMS features')

