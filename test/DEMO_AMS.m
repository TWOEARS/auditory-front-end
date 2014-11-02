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
requests = {'modulation'};

% Window size in seconds
nChannels   = [32];
rm_wSizeSec = 20E-3;
rm_wStepSec = 10E-3; % DO NOT CHANGE!!!
rm_decaySec = 8E-3;

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',nChannels,...
                   'rm_wSizeSec',rm_wSizeSec,'rm_hSizeSec',rm_wStepSec,...
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


[nFrames,nChannels] = size(rm_feat');

wSizeSamples = 0.5 * round((rm_wSizeSec * fsHz * 2));
wStepSamples = round((rm_wStepSec * fsHz));

timeSec = (wSizeSamples + (0:nFrames-1)*wStepSamples)/fsHz;


figure;
imagesc(timeSec,1:nChannels,rm_feat);axis xy;
colorbar;
xlim([timeSec(1) timeSec(end)])
set(gca,'CLim',[-100 -25])
title('Ratemap')
xlabel('Time (s)')
ylabel('\# channels')
% subplot(1,3,2);
% imagesc(gb_feat);axis xy;
% title('Gabor features')
% subplot(1,3,3);

figure;
imagesc(timeSec,1:size(gb_feat_N),gb_feat_N);axis xy;
xlim([timeSec(1) timeSec(end)])
colorbar;
xlabel('Time (s)')
ylabel('\# feature dimensions')
title('Gabor features')

if 1
    fig2LaTeX('Gabor_01',1,16);
    fig2LaTeX('Gabor_02',2,16);
end