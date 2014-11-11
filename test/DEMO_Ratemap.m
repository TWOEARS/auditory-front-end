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
requests = {'ratemap'};

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',64,'ihc_method','dau'); 
par2 = genParStruct('rm_scaling','magnitude','gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',64,'ihc_method','dau'); 


% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);
mObj.addProcessor(requests,par2);

% Request processing
mObj.processSignal();


%% Plot Gammatone response
% 
% 
% Envelope
env  = [dObj.innerhaircell{1}.Data(:,:)];
fHz  = dObj.gammatone{1}.cfHz;
tSec = (1:size(env,1))/fsHz;

zoom  = [];
bNorm = [];

figure;
waveplot(env(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);


dObj.ratemap{1}.plot;
