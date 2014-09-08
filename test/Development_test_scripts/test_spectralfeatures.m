% Develop spectral features

clear;
close all
clc

%% Load a signal

% Add paths
path = fileparts(mfilename('fullpath')); 
run([path filesep '..' filesep '..' filesep 'src' filesep 'startWP2.m'])

% Load a signal
load('TestBinauralCues');

data = earSignals(:,2);     % Take channel with higher energy

% Zero-padding
% data = [zeros(10E3,1); data];
% data = randn(size(data));
% [b,a] = butter(5,50/(fsHz*0.5));
% data=filter(b,a,data);

% data = earSignals;
fs = fsHz;
clear earSignals fsHz

% Request ratemap    
requests = {'ratemap_power'};

% Parameters
par = genParStruct('f_low',80,'f_high',8000,'nChannels',16); 

% Create a data object
dObj = dataObject(data,fs);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Derive spectral features
% 
% 
% Copy ratemap
rMap = dObj.ratemap_power{1}.Data;
fHz  = dObj.ratemap_power{1}.cfHz;

% Determine size of input
[nFrames,nFreq] = size(rMap);


%% Spectral centroid
% 
% 
spec_centroid = calcSpecCentroid(rMap,fHz);


%% Spectral crest measure
% 
% 
spec_crest = calcSpecCrest(rMap);


%% Spectral decrease
% 
% 
spec_decrease = calcSpecDecrease(rMap);


%% Spectral spread
% 
% 
spec_spread = calcSpecBandwidth(rMap,fHz);


%% Spectral brightness
% 
% 
spec_brightness = calcSpecBrightness(rMap,fHz);


%% Spectral high frequency content
% 
% 
spec_hfc = calcSpecHFC(rMap,fHz);


%% Spectral entropy
% 
% 
spec_entropy = calcSpecEntropy(rMap);


%% Spectral flatness
% 
% 
spec_flatness = calcSpecFlatness(rMap);


%% Spectral flux
% 
% 
spec_flux = calcSpecFlux(rMap);


%% Spectral kurtosis
% 
% 
spec_kurtosis = calcSpecKurtosis(rMap);


%% Spectral skewness
% 
% 
spec_skewness = calcSpecSkewness(rMap);


%% Spectral irregularity
% 
% 
spec_irregularity = calcSpecIrregularity(rMap);


%% Spectral rolloff
% 
% 
spec_rolloff = calcSpecRolloff(rMap,fHz);


%% Spectral variation
% 
% 
spec_variation = calcSpecVariation(rMap);


%% Plot 
% 
% 
figure;
imagesc(1:nFrames,fHz,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_centroid,'k--','linewidth',2)
title('Spectral centroid')

figure;
imagesc(1:nFrames,1:nFreq,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_crest,'k--','linewidth',2)
title('Spectral crest measure')

figure;
imagesc(1:nFrames,fHz,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_spread,'k--','linewidth',2)
title('Spectral spread')

figure;
imagesc(1:nFrames,(1:nFreq)./nFreq,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_entropy,'k--','linewidth',2)
title('Spectral entropy')

figure;
imagesc(1:nFrames,(1:nFreq)./nFreq,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_brightness,'k--','linewidth',2)
title('Spectral brightness')

figure;
imagesc(1:nFrames,(1:nFreq)./nFreq,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_hfc,'k--','linewidth',2)
title('Spectral high frequency content')

figure;
imagesc(1:nFrames,(1:nFreq)./nFreq,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_decrease,'k--','linewidth',2)
title('Spectral decrease')

figure;
imagesc(1:nFrames,(1:nFreq)./nFreq,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_flatness,'k--','linewidth',2)
title('Spectral flatness')

figure;
imagesc(1:nFrames,1:nFreq,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_flux,'k--','linewidth',2)
title('Spectral flux')

figure;
imagesc(1:nFrames,1:nFreq,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_kurtosis,'k--','linewidth',2)
title('Spectral kurtosis')

figure;
imagesc(1:nFrames,1:nFreq,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_skewness,'k--','linewidth',2)
title('Spectral skewness')

figure;
imagesc(1:nFrames,1:nFreq,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_irregularity,'k--','linewidth',2)
title('Spectral irregularity')

figure;
imagesc(1:nFrames,fHz,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_rolloff,'k--','linewidth',2)
title('Spectral rolloff')

figure;
imagesc(1:nFrames,(1:nFreq)./nFreq,20*log10(rMap'));axis xy;
hold on;
plot(1:nFrames,spec_variation,'k--','linewidth',2)
title('Spectral variation')



