clear;
close all
clc


%% Load a signal

% Add paths
% path = fileparts(mfilename('fullpath')); 
% run([path filesep '..' filesep 'src' filesep 'startAuditoryFrontEnd.m'])
% 
% addpath(['Test_signals',filesep]);

% Load a signal
load('TestBinauralCues');

% Take right ear signal
data = earSignals(:,2);     
% data = data + 10*rand(size(data));

fs = fsHz;
clear earSignals fsHz

% Request ratemap    
requests = {'ratemap_power'};

% Parameters
par = genParStruct('f_low',80,'f_high',8000,'nChannels',[]); 

% Create a data object
dObj = dataObject(data,fs);

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
tSec = (1:size(bm,1))/fs;

zoom  = [];
bNorm = [];

waveplot(bm)

figure;
ax1 = subplot(3,1,1);
plot(tSec,data);
xlabel('Time (s)')
ylabel('Amplitude')
xlim([tSec(1) tSec(end)]);

ax2 = subplot(3,1,[2 3]);
waveplot(bm,tSec,fHz,zoom,bNorm,ax2);
linkaxes([ax1 ax2],'x');
