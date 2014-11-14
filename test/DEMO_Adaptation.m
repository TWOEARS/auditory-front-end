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
requests = {'adaptation'};

% Parameters of Gammatone processor
fb_type       = 'gammatone';
fb_nChannels  = 16;  
fb_lowFreqHz  = 80;
fb_highFreqHz = 8000;

% Parameters 
par = genParStruct('fb_type',fb_type,...
                   'fb_lowFreqHz',fb_lowFreqHz,...
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
wavPlotZoom = 3; % Zoom factor
wavPlotDS   = 1; % Down-sampling factor

% Summarize plot parameters
p = genParStruct('wavPlotZoom',wavPlotZoom,'wavPlotDS',wavPlotDS);

% Plot innerhaircell signal
dObj.innerhaircell{1}.plot([],p)

% Plot adaptation signal
dObj.adaptation{1}.plot([],p)

