clear;
close all
clc


%% Create binaural input signal
% 
% 
% Load a signal
load(['Test_signals',filesep,'TestBinauralCues']);

% Ear signals
earSignals = fliplr(earSignals);

% Replicate signals at a higher level
earSignals = cat(1,earSignals,5*earSignals);

% Add a sinus @ 0.5 Hz
data = earSignals + repmat(sin(2*pi.*(0:size(earSignals,1)-1).' * 0.5/fsHz),[1 size(earSignals,2)]);

% Time axis
timeSec = (1:size(data,1))/fsHz;


%% Pre-processing settings
% 
% 
% Activate DC removal filter
bRemoveDC = true;
cutoffHz  = 20;

% Activate pre-whitening
bWhitening = false;

% Activate RMS normalization
bNormalizeRMS = true;
rmsIntTimeSec = 500E-3;   
    
% Reference sampling frequency
fsHzRef = [];


%% Plot signal
% 
% 
% Number of subplots
nSubplots = 2 + sum([bRemoveDC bWhitening 2 * bNormalizeRMS]);

ctrSubPlot = 1;

figure;
ax(1) = subplot(nSubplots,1,1);
plot(timeSec,earSignals);
title('Ears signal')

ctrSubPlot = ctrSubPlot + 1;

ax(ctrSubPlot) = subplot(nSubplots,1,ctrSubPlot);
plot(timeSec,data);
title('Ear signals + sinus at 0.5 Hz')


%% DC removal filter
%
%
if bRemoveDC
    % 4th order @ 20 Hz cutoff
    [bDC,aDC] = butter(4,cutoffHz/(fsHz * 0.5),'high');
    
    if isstable(bDC,aDC)
        data = filter(bDC,aDC,data);
    else
        error('IIR filter is not stable, reduce the filter order!')
    end
    
    ctrSubPlot = ctrSubPlot + 1;
    
    ax(ctrSubPlot) = subplot(nSubplots,1,ctrSubPlot);
    plot(timeSec,data);
    title('After DC removal')
end


%% Resampling
%
%
if isempty(fsHzRef) 
    % Do nothing
elseif fsHz > fsHzRef
    % Resample signal
    data = resample(data,fsHzRef,fsHz);
    
    % Re-create time axis
    timeSec = (1:size(data,1))/fsHzRef;
else
    error('Upsampling of the input signal is not supported.')
end        


%% Pre-whitening
% 
%
if bWhitening
    % Common choices are between 0.9 and 0.97
    b = [1 -0.97];
    a = 1;
    
    % Apply 1st order pre-whitening filter
    data = filter(b, a, data);
    
    ctrSubPlot = ctrSubPlot + 1;
    
    ax(ctrSubPlot) = subplot(nSubplots,1,ctrSubPlot);
    plot(timeSec,data);
    title('After whitening')
end


%% Perform AGC
%
%
if bNormalizeRMS
    % Apply AGC to all channels independently
    out1 = agc(data,fsHz,rmsIntTimeSec,false);
    
    % Preserve level differences across channels
    out2 = agc(data,fsHz,rmsIntTimeSec,true);
    
    ctrSubPlot = ctrSubPlot + 1;
    
    ax(ctrSubPlot) = subplot(nSubplots,1,ctrSubPlot);
    plot(timeSec,out1);
    title('After monaural AGC')
    
    ctrSubPlot = ctrSubPlot + 1;
    
    ax(ctrSubPlot) = subplot(nSubplots,1,ctrSubPlot);
    plot(timeSec,out2);
    title('After binaural AGC')
end

linkaxes(ax(:),'x');
axis tight;
