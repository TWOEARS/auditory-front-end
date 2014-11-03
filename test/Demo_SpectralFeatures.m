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
requests = {'spectral_features'};

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

ratemap = [dObj.ratemap_power{1}.Data(:)];
spectralFeatures = [dObj.spectral_features{1}.Data(:)];

cfHz = dObj.ratemap_power{1}.cfHz;

[nFrames,nChannels] = size(ratemap);

wSizeSamples = 0.5 * round((rm_wSizeSec * fsHz * 2));
wStepSamples = round((rm_hSizeSec * fsHz));

timeSec = (wSizeSamples + (0:nFrames-1)*wStepSamples)/fsHz;

listOfFeatures = dObj.spectral_features{1}.fList;


%% Plot spectral features
% 
% 
strColor = 'k';
strLineStyle = '-';
strLineWidth = 1;

input = [dObj.time{1}.Data(:)];

figure;
plot((1:numel(input))/fsHz,input,'b');
xlim([timeSec(1) timeSec(end)])
ylim([-1.125 1.125])
xlabel('Time (s)')
ylabel('Amplitude')
title('Time domain signal')
grid on;


if any(strcmp(listOfFeatures,'centroid'))
    figure;
    imagesc(timeSec,(1:nChannels)/nChannels,10*log10(ratemap'));axis xy;
    hold on;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'centroid')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Normalized frequency')
    title('Spectral centroid')
end

if any(strcmp(listOfFeatures,'spread'))
    figure;
    imagesc(timeSec,(1:nChannels)/nChannels,10*log10(ratemap'));axis xy;
    hold on;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'spread')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Normalized frequency')
    title('Spectral spread')
end


if any(strcmp(listOfFeatures,'rolloff'))
    figure;
    imagesc(timeSec,(1:nChannels)/nChannels,10*log10(ratemap'));axis xy;
    hold on;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'rolloff')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Normalized frequency')
    title('Spectral rolloff')
end


if any(strcmp(listOfFeatures,'brightness'))
    figure;
    imagesc(timeSec,(1:nChannels)/nChannels,10*log10(ratemap'));axis xy;
    hold on;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'brightness')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Normalized frequency')
    title('Spectral brightness')
end


if any(strcmp(listOfFeatures,'flatness'))
    figure;
    imagesc(timeSec,(1:nChannels)/nChannels,10*log10(ratemap'));axis xy;
    hold on;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'flatness')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Normalized frequency')
    title('Spectral flatness')
end


if any(strcmp(listOfFeatures,'variation'))
    figure;
    imagesc(timeSec,(1:nChannels)/nChannels,10*log10(ratemap'));axis xy;
    hold on;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'variation')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Normalized frequency')
    title('Spectral variation')
end


if any(strcmp(listOfFeatures,'crest'))
    figure;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'crest')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    grid on;
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('Spectral crest measure')
end


if any(strcmp(listOfFeatures,'entropy'))
    figure;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'entropy')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    grid on;
    xlim([timeSec(1) timeSec(end)])
    ylim([0 1])
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('Spectral entropy')
end


if any(strcmp(listOfFeatures,'hfc'))
    figure;
    plot(timeSec,1E-6*spectralFeatures(:,strcmp(listOfFeatures,'hfc')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    grid on;
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Amplitude ($\times$ 1E6)')
    title('Spectral high frequency content')
end


if any(strcmp(listOfFeatures,'decrease'))
    figure;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'decrease')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    grid on;
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('Spectral decrease')
end


if any(strcmp(listOfFeatures,'flux'))
    figure;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'flux')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    grid on;
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('Spectral flux')
end


if any(strcmp(listOfFeatures,'kurtosis'))
    figure;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'kurtosis')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    grid on;
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('Spectral kurtosis')
end


if any(strcmp(listOfFeatures,'skewness'))
    figure;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'skewness')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    grid on;
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('Spectral skewness')
end


if any(strcmp(listOfFeatures,'irregularity'))
    figure;
    plot(timeSec,spectralFeatures(:,strcmp(listOfFeatures,'irregularity')),'linestyle',strLineStyle,'color',strColor,'linewidth',strLineWidth);
    grid on;
    xlim([timeSec(1) timeSec(end)])
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('Spectral irregularity')
end

if 0
    for ii = 1 : numel(listOfFeatures) + 1
        fig2LaTeX(['SpectralFeature_',num2str(ii)],ii,20);
    end
end

