clear;
close all
clc


%% LOAD SIGNAL
% 
% 
% Load a signal
load('AFE_earSignals_16kHz');

% Create a data object based on parts of the right ear signal
dObj = dataObject(earSignals(1:20E3,2),fsHz);


%% PLACE REQUEST AND CONTROL PARAMETERS
% 
% 
% Request gammatone processor
requests = {'gammatone'};

% Parameters of Gammatone processor
fb_nChannels  = 16;  
fb_lowFreqHz  = 80;
fb_highFreqHz = 8000;

% Parameters 
par = genParStruct('fb_lowFreqHz',fb_lowFreqHz,...
                   'fb_highFreqHz',fb_highFreqHz,...
                   'fb_nChannels',fb_nChannels);
                   

%% PERFORM PROCESSING
% 
% 
% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% PLOT RESULTS
% 
% 
% Plot-related parameters
wavPlotZoom = 5; % Zoom factor
wavPlotDS   = 3; % Down-sampling factor

% Summarize plot parameters
p = genParStruct('wavPlotZoom',wavPlotZoom,'wavPlotDS',wavPlotDS);

% Plot time domain signal
dObj.time{1}.plot

% Plot gammatone signal
dObj.gammatone{1}.plot([],p);
title('Gamatone response')
