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
ams_lowFreqHz  = [4];
ams_highFreqHz = [1024];
ams_dsRatio    = 1; 
ams_wSizeSec   = 32E-3;
ams_hSizeSec   = 16E-3;
ams_wname      = 'hamming';

% Number of auditory channels
nChannels    = [30];

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',nChannels,'ams_wSizeSec',ams_wSizeSec,'ams_hSizeSec',ams_hSizeSec,...
                   'ams_fbType',ams_fbType,'ams_dsRatio',ams_dsRatio,'ams_nFilters',ams_nFilters,'ams_lowFreqHz',ams_lowFreqHz,'ams_highFreqHz',ams_highFreqHz,'ams_wname',ams_wname); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();

% Plot time domain signal
dObj.time{1}.plot;grid on;ylim([-1 1]);title('Time domain signal')

% Plot IHC signal
% dObj.innerhaircell{1}.plot;title('IHC')

% Envelope
env  = [dObj.innerhaircell{1}.Data(:,:)];
fHz  = dObj.gammatone{1}.cfHz;
tSec = (1:size(env,1))/fsHz;

zoom  = [];
bNorm = [];

figure;
waveplot(env(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);
title('IHC')


% Plot AMS pattern
dObj.ams_features{1}.plot

