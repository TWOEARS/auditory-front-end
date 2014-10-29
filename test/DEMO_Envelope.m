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
requests = {'ratemap_power'};

% Parameters
par = genParStruct('f_low',80,'f_high',8000,'nChannels',[16],'IHCMethod','dau'); 

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

zoom  = [];
bNorm = [];


figure;
waveplot(bm(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);

figure;
waveplot(env(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);

