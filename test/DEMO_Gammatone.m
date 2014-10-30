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
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',16); 

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
fHz  = dObj.gammatone{1}.cfHz;
tSec = (1:size(bm,1))/fsHz;

zoom  = [];
bNorm = [];


figure;
plot(tSec(1:3:end),data(1:3:end));
xlabel('Time (s)')
ylabel('Amplitude')
xlim([tSec(1) tSec(end)]);
ylim([-1 1])

figure;
waveplot(bm(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);

