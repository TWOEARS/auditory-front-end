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
requests = {'onset_map'};

rm_wSizeSec = 20E-3;
rm_hSizeSec = 10E-3;
rm_decaySec = 8E-3;

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',64,'ihc_method','dau','rm_decaySec',rm_decaySec,'rm_wSizeSec',rm_wSizeSec,'rm_hSizeSec',rm_hSizeSec); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Plot ratemap, onset strength and onset map
% 
% 
dObj.ratemap_power{1}.plot;
dObj.onset_strength{1}.plot;
dObj.onset_map{1}.plot;


