clear;
close all
clc

% Load a signal
load('TestBinauralCues');

% Take right ear signal
data = earSignals(1:62E3,2);     

% New sampling frequency
fsHzRef = 16E3;

% Resample
data = resample(data,fsHzRef,fsHz);

% Copy fs
fsHz = fsHzRef;

% Request ratemap    
requests = {'spectral_features'};

% Ratemap parameters
rm_wSizeSec = 20E-3;
rm_hSizeSec = 10E-3;
rm_decaySec = 8E-3;
rm_scaling  = 'power';

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',64,'ihc_method','dau','rm_decaySec',rm_decaySec,'rm_wSizeSec',rm_wSizeSec,'rm_hSizeSec',rm_hSizeSec,'rm_scaling',rm_scaling); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Plot spectral features
% 
% 

% Plot time domain signal
dObj.time{1}.plot

% Plot spectral features
rmap = dObj.ratemap_power{1};   % Handle to the ratemap for plot overlay
dObj.spectral_features{1}.plot([],[],'overlay',rmap,'noSubPlots',1);




%% Save figures
if 0
    listOfFeatures = dObj.spectral_features{1}.fList;
    for ii = 1 : numel(listOfFeatures) + 1
        fig2LaTeX(['SpectralFeature_',num2str(ii)],ii,20);
    end
end

