clear;
close all
clc


% Load a signal
load('TestBinauralCues');

% Take right ear signal
data = earSignals(1:62E3,2);     
% data = earSignals(1:15E3,2);     

% New sampling frequency
fsHzRef = 30E3;

% Resample
data = resample(data,fsHzRef,fsHz);

% Copy fs
fsHz = fsHzRef;

% Request ratemap    
requests = {'autocorrelation'};


ac_wSizeSec  = 0.02;
ac_hSizeSec  = 0.01;
ac_clipAlpha = 0;
ac_K         = 2;

  
% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',16,'ihc_method','dau','ac_wSizeSec',ac_wSizeSec,'ac_hSizeSec',ac_hSizeSec,'ac_clipAlpha',ac_clipAlpha,'ac_K',ac_K); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();

acf = [dObj.autocorrelation{1}.Data(:)];


figure;
waveplot(permute(acf(50,:,:),[3 1 2]))


% %% Plot Gammatone response
% % 
% % 
% % Basilar membrane output
% bm   = [dObj.gammatone{1}.Data(:,:)];
% % Envelope
% env  = [dObj.innerhaircell{1}.Data(:,:)];
% fHz  = dObj.gammatone{1}.cfHz;
% tSec = (1:size(bm,1))/fsHz;
% 
% zoom  = [];
% bNorm = [];
% 
% 
% figure;
% waveplot(bm(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);
% 
% figure;
% waveplot(env(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);

