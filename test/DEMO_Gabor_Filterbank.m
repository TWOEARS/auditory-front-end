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

% Window size in seconds
winSizeSec  = 32E-3;
winStepSec  = 10E-3; % DO NOT CHANGE!!!
rm_decaySec = 8E-3;

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',[],...
                   'rm_wSizeSec',winSizeSec,'rm_hSizeSec',winStepSec,...
                   'rm_decaySec',rm_decaySec); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Perform Gabor transformation
% 
% 
% Get ratemap representation
rm_feat = transpose([dObj.ratemap_power{1}.Data(:,:)]);

% Apply static compression
rm_feat = 10 * log10(rm_feat);

% Compute Gabor features
gb_feat = gbfb(rm_feat);

% Normalize Gabor features
gb_feat_N = normalizeData(gb_feat','meanvar')';

figure;
subplot(1,3,1);
imagesc(rm_feat);axis xy;
title('Ratemap')
subplot(1,3,2);
imagesc(gb_feat);axis xy;
title('Gabor features')
subplot(1,3,3);
imagesc(gb_feat_N);axis xy;
title('Gabor features normalized')
