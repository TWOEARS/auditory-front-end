clear;
close all
clc


% Load a signal
load('TestBinauralCues');

% Take right ear signal
data = earSignals(1:62E3,2);     
% data = earSignals(1:15E3,2);     

% New sampling frequency
fsHzRef = 16E3;

% Resample
data = resample(data,fsHzRef,fsHz);

% Copy fs
fsHz = fsHzRef;

% Request ratemap    
requests = {'adaptation'};

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',16,'ihc_method','dau'); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Plot Gammatone response
% 
% 
% Basilar membrane output
bm   = [dObj.gammatone{1}.Data(:,:)];
% Envelope
env  = [dObj.innerhaircell{1}.Data(:,:)];
fHz  = dObj.gammatone{1}.cfHz;
tSec = (1:size(bm,1))/fsHz;
% Adaptation output
adt = [dObj.adaptation{1}.Data(:,:)];

zoom  = [];
bNorm = [];


figure;
waveplot(bm(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);

figure;
waveplot(env(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);

figure;
% Try different zoom value for the adaptation output (output unit /
% amplitude range change)
waveplot(adt(1:3:end,:),tSec(1:3:end),fHz,3,bNorm);