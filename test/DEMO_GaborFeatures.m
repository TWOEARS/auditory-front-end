clear;
close all
clc


%% LOAD SIGNAL
% 
% 
% Load a signal
load('AFE_earSignals_16kHz');

% Create a data object based on parts of the ear signals
dObj = dataObject(earSignals(1:20E3,:),fsHz);


%% PLACE REQUEST AND CONTROL PARAMETERS
% 
% 
% Request ratemap    
requests = {'ratemap'};

% Following the ETSI standard
nChannels  = [23];
lowFreqHz  = 124;
highFreqHz = 3657;

% Window size in seconds
rm_wSizeSec = 25E-3;
rm_wStepSec = 10E-3; % DO NOT CHANGE!!!
rm_decaySec = 8E-3;

% Parameters
par = genParStruct('gt_lowFreqHz',lowFreqHz,'gt_highFreqHz',highFreqHz,'gt_nChannels',nChannels,...
                   'rm_wSizeSec',rm_wSizeSec,'rm_hSizeSec',rm_wStepSec,...
                   'rm_decaySec',rm_decaySec); 


%% PERFORM PROCESSING
% 
% 
% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Perform Gabor transformation
% 
% 
% Limit dynamic range of ratemap representation
maxDynamicRangedB = 80;

% Get ratemap representation
rm_feat = transpose([dObj.ratemap{1}.Data(:,:)]);

% Maximum ratemap power
max_pow = max(rm_feat(:));

% Minimum ratemap floor to limit dynamic range
min_pow = db2pow(-(maxDynamicRangedB + (0 - pow2db(max_pow))));

% Apply static compression
rm_feat = pow2db(rm_feat + min_pow);

% Compute Gabor features
gb_feat = gbfb(rm_feat);

% Normalize Gabor features
gb_feat_N = normalizeData(gb_feat','meanvar')';

% Quantize colorbar resolution
resolutiondB = 5;

% Colorbar limits
clim = [quant(pow2db(min_pow),resolutiondB) quant(pow2db(max_pow),resolutiondB)];


[nFrames,nChannels] = size(rm_feat');

wSizeSamples = 0.5 * round((rm_wSizeSec * fsHz * 2));
wStepSamples = round((rm_wStepSec * fsHz));

timeSec = (wSizeSamples + (0:nFrames-1)*wStepSamples)/fsHz;



figure;
imagesc(timeSec,1:nChannels,rm_feat);axis xy;
colorbar;
xlim([timeSec(1) timeSec(end)])
set(gca,'CLim',[quant(pow2db(min_pow),5) quant(pow2db(max_pow),5)])
title('Ratemap')
xlabel('Time (s)')
ylabel('\# channels')

figure;
imagesc(timeSec,1:size(gb_feat_N),gb_feat_N);axis xy;
xlim([timeSec(1) timeSec(end)])
colorbar;
xlabel('Time (s)')
ylabel('\# feature dimensions')
title('Gabor features')

% if 1
%     fig2LaTeX('Gabor_01',1,16);
%     fig2LaTeX('Gabor_02',2,16);
% end