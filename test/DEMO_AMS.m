clear;
close all
clc


% Load a signal
load('TestBinauralCues');

% Take right ear signal
% data = earSignals(1:62E3,2);     
data = earSignals(:,2);     

% New sampling frequency
fsHzRef = 16E3;

% Resample
data = resample(data,fsHzRef,fsHz);

% Copy fs
fsHz = fsHzRef;

% Request ratemap    
requests = {'ams_features'};

% Linear versus logarithmic
ams_fbType     = 'log';
ams_nFilters   = [];
ams_lowFreqHz  = [];
ams_highFreqHz = [];
ams_dsRatio    = 1; 
ams_wSizeSec   = 32E-3;
ams_hSizeSec   = 16E-3;
ams_wname      = 'hamming';

% Number of auditory channels
nChannels    = [23];

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',nChannels,'ams_wSizeSec',ams_wSizeSec,'ams_hSizeSec',ams_hSizeSec,...
                   'ams_fbType',ams_fbType,'ams_dsRatio',ams_dsRatio,'ams_nFilters',ams_nFilters,'ams_lowFreqHz',ams_lowFreqHz,'ams_highFreqHz',ams_highFreqHz,'ams_wname',ams_wname); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();

% Plot AMS pattern
dObj.ams_features{1}.plot

