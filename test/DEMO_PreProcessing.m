clear;
close all
clc


%% Load a signal
load(['Test_signals',filesep,'TestBinauralCues']);

% Ear signals
speech = fliplr(earSignals);

% Add a sinus 
fHz = 0.5;

% Imprint amplitude modulation
data = speech .* repmat(sin(2*pi.*(0:size(speech,1)-1).' * fHz/fsHz),[1 size(speech,2)]);

fs = fsHz;
clear earSignals fsHz


%% Preprocessing settings
% 
% 
% Activate DC removal filter
bRemoveDC = true;

% Activate pre-whitening
bWhitening = false;

% Activate RMS normalization
bNormalize = true;


%% DC removal filter
%
%
if bRemoveDC
    % 4th order @ 20 Hz cutoff
    [bDC,aDC] = butter(4,20/(fs * 0.5),'high');
    
    if isstable(bDC,aDC)
        data = filter(bDC,aDC,data);
    else
        error('IIR filter is not stable, reduce the filter order!')
    end
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
end


%% Perform AGC
%
%
if bNormalize
    % Integration constant in seconds
    timeSec = 500E-3;
    
    % Apply AGC to all channels independently
    out1 = agc(data,fs,timeSec,false,true);
    
    % Preserve level differences across channels
    out2 = agc(data,fs,timeSec,true,true);
end

