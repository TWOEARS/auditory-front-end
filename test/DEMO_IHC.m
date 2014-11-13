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
% Request innerhaircell processor    
requests = {'innerhaircell'};

% Parameters of Gammatone processor
gt_nChannels  = 16;  
gt_lowFreqHz  = 80;
gt_highFreqHz = 8000;

% Parameters of innerhaircell processor
ihc_method    = 'dau';

% Parameters 
par = genParStruct('gt_lowFreqHz',gt_lowFreqHz,'gt_highFreqHz',gt_highFreqHz,...
                   'gt_nChannels',gt_nChannels,'ihc_method',ihc_method); 
               

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

% Plot gammatone responses
dObj.gammatone{1}.plot([],p);
title('Gamatone response')

% Plot IHC responses
dObj.innerhaircell{1}.plot([],p);
title('IHC signal')