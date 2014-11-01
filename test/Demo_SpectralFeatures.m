clear;
% close all
clc

% Load a signal
load('TestBinauralCues');

% Take right ear signal
data = earSignals(1:62E3,2);     

% data = data / 10;

% New sampling frequency
fsHzRef = 16E3;

% Resample
data = resample(data,fsHzRef,fsHz);

% Copy fs
fsHz = fsHzRef;

% Request ratemap    
requests = {'spec_features'};

% Ratemap parameters
rm_wSizeSec = 20E-3;
rm_hSizeSec = 10E-3;
rm_decaySec = 8E-3;
rm_scaling  = 'power';

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',64,'ihc_method','dau','rm_decaySec',rm_decaySec,'rm_wSizeSec',rm_wSizeSec,'rm_hSizeSec',rm_hSizeSec,'rm_scaling',rm_scaling); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


dObj.spec_features{1}.plot

% %% Plot Gammatone response
% % 
% % 
% % Envelope
% env  = [dObj.innerhaircell{1}.Data(:,:)];
% fHz  = dObj.gammatone{1}.cfHz;
% tSec = (1:size(env,1))/fsHz;
% 
% zoom  = [];
% bNorm = [];
% 
% figure;
% waveplot(env(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);
% 
% 
% dObj.ratemap_power{1}.plot;
