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
% Request ratemap    
requests = {'ratemap'};

% Parameters of Gammatone processor
gt_nChannels  = 64;  
gt_lowFreqHz  = 80;
gt_highFreqHz = 8000;

% Parameters of innerhaircell processor
ihc_method    = 'dau';

% Parameters of ratemap processor
rm_wSizeSec  = 0.02;
rm_hSizeSec  = 0.01;
rm_scaling   = 'magnitude';
rm_decaySec  = 8E-3;
rm_wname     = 'hann';

% Parameters 
par = genParStruct('gt_lowFreqHz',gt_lowFreqHz,'gt_highFreqHz',gt_highFreqHz,...
                   'gt_nChannels',gt_nChannels,'ihc_method',ihc_method,...
                   'ac_wSizeSec',rm_wSizeSec,'ac_hSizeSec',rm_hSizeSec,...
                   'rm_scaling',rm_scaling,'rm_decaySec',rm_decaySec,...
                   'ac_wname',rm_wname); 


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

% Plot ratemap
dObj.ratemap{1}.plot;

% Plot IHC signal
dObj.innerhaircell{1}.plot([],p);
title('IHC signal')
