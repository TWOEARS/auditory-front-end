clear;
close all
clc


%% LOAD SIGNAL
% 
% 
% Load a signal
load('Test_signals/AFE_earSignals_16kHz');

% Create a data object based on parts of the right ear signal
dObj = dataObject(earSignals(1:22495,2),fsHz);


%% PLACE REQUEST AND CONTROL PARAMETERS
% 
% 
% Request ratemap    
requests = {'ratemap', 'stft'};

% Parameters of auditory filterbank 
fb_type       = 'gammatone';
fb_lowFreqHz  = 80;
fb_highFreqHz = 8000;
fb_nChannels  = 64;  

% Parameters of innerhaircell processor
ihc_method    = 'dau';

% Parameters of ratemap processor
rm_wSizeSec  = 0.02;
rm_hSizeSec  = 0.01;
rm_scaling   = 'magnitude';
rm_decaySec  = 8E-3;
rm_wname     = 'hann';

% Parameters of ratemap processor
stft_wSizeSec = 20E-3;
stft_isPruned = true;

% Summary of parameters 
par = genParStruct('fb_type',fb_type,'fb_lowFreqHz',fb_lowFreqHz,...
                   'fb_highFreqHz',fb_highFreqHz,'fb_nChannels',fb_nChannels,...
                   'ihc_method',ihc_method,'ac_wSizeSec',rm_wSizeSec,...
                   'ac_hSizeSec',rm_hSizeSec,'rm_scaling',rm_scaling,...
                   'rm_decaySec',rm_decaySec,'ac_wname',rm_wname,...
                   'stft_wSizeSec',stft_wSizeSec,'stft_isPruned',stft_isPruned); 


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
dObj.stft{1}.plot;