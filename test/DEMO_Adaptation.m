clear;
close all
clc


% Load a signal
load('TestBinauralCues');

% Take right ear signal
data = earSignals(1:62E3,2);     
% data = earSignals(1:15E3,2);   

% % A simpler signal (silence - ramp - steday-state - ramp - silence)
% % as in the demo in AMToolbox (demo_adaploop.m) 
% fsHz=10000;
% minlvl=setdbspl(0);
% duration = 0.4;                
% beginSilence=0.2;
% endSilence=0.4;
% rampDuration=0.1;              
% 
% dt=1/fsHz; % seconds
% time=dt: dt: duration;
% inputSignal=ones(1, length(time));      
% 
% rampTime=dt:dt:rampDuration;
% ramp=[sin(pi*rampTime/(2*rampDuration)) ...
%     ones(1,length(time)-length(rampTime))];
% inputSignal=inputSignal.*ramp;
% ramp=fliplr(ramp);
% inputSignal=inputSignal.*ramp;
% 
% intialSilence = zeros(1,round(beginSilence/dt));
% finalSilence = zeros(1,round(endSilence/dt));
% inputSignal = [intialSilence inputSignal finalSilence];
% inputSignal = max(inputSignal,minlvl);
% data = inputSignal.';
% x = (0:length(inputSignal)-1)/fsHz;


% New sampling frequency
fsHzRef = 16E3;

% Resample
data = resample(data,fsHzRef,fsHz);

% Copy fs
fsHz = fsHzRef;

% Request ratemap    
requests = {'adaptation'};

% Parameters
par = genParStruct('fb_lowFreqHz',80,'fb_highFreqHz',8000,'fb_nChannels',16,'ihc_method','dau'); 

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