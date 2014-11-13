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
requests = {'offset_map'};

rm_wSizeSec = 20E-3;
rm_hSizeSec = 10E-3;
rm_decaySec = 8E-3;

% Parameters
par = genParStruct('fb_lowFreqHz',80,'fb_highFreqHz',8000,'fb_nChannels',64,'ihc_method','dau','rm_decaySec',rm_decaySec,'rm_wSizeSec',rm_wSizeSec,'rm_hSizeSec',rm_hSizeSec); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Plot offset strength in dB
% 
% 
dObj.ratemap_power{1}.plot;
dObj.offset_strength{1}.plot;

% Plot offsets in white
p = genParStruct('binaryMaskColor',[1 1 1]);
dObj.offset_map{1}.plot([],p);
