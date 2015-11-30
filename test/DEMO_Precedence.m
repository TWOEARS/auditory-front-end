clear;
close all
clc

%% LOAD SIGNAL

% Input signal, created for the demo using stimulusBraasch function
% (see below for the input parameters and usage)

fsHz = 48000;           % Sampling Frequency [Hz]
waveForm = 2;           % Used for the stimulusBraasch function
% integer to select a waveform:
%           0 - Sine Wave
%           1 - Triangle Wave
%           2 - Bandpass Noise
%           3 - White Noise (Uniform Distribution)
%           4 - Two sine waves (1st & 3rd harmonics; f = f of 2nd harmonic)
%           5 - Three sine waves (1st, 2nd & 3rd harmonics; f = f of 2nd harmonic)
%           6 - peak train

length = 400;           % Signal length in ms
fc = 500;               % For periodic waves: Frequency in Hz,
                        % For Bandpass Noise: Fc of the bandpass filter
bw = 800;               % Bandwidth of the FFT bandpass filters
itd = 0.6;              % ITD in ms (applied in positive/negative pair to 
                        % stimulusBraasch function)                      
ISI = 3;                % Inter-Stimulus Interval in ms
attackTime = 20;        % Attach time in ms
decayTime = 20;         % Decay time in ms
operationMode = 0;      % Used for the stimulusBraasch function
%           0: specified operation (both lead and lag are present), 
%           1: switch off the lead, 2: switch off the lag

lagLevel = 0;           % Lag level in dB

% Binaural test stimulus using Braasch's function
% Usage: 
%   stimulusBraasch(Fs, mode, len, f, bw, itd1, itd2, isi, at, dc, nn, lag_level)
% This function is copied from Braasch's model into AFE src/Tools folder.
% Parameters:
% 
%         Fs:    sampling frequency
%         mode:  integer to select a waveform
%         len:   Signal length in milliseconds
%         f:     For periodic waves: Frequency in Hz
%                For Bandpass Noise: Fc of the bandpass filter
%         bw:    Bandwidth of the FFT bandpass filters
%         itd1,
%         itd2:  ITDs in milliseconds
%               (positive for right channel first - left channel last,
%               negative for left channel first - right channel last)
%               Indices 1 and 2 correspond to the incidence of the
%               the two signals.
%         isi:   ISI in milliseconds
%         at:    attack time (ms)
%         dc:    decay time (ms)
%         nn:    0: specified operation, 1: switch off S1, 2: switch off S2
%         lag_level: lag level in dB

x = stimulusBraasch(fsHz, waveForm, length, fc, bw, ...
    itd, -itd, ...
    ISI, attackTime, decayTime, ...
    operationMode, ...
    db2amp(lagLevel));

% Create a data object
dObj = dataObject(x, fsHz);


%% PLACE REQUEST AND CONTROL PARAMETERS

requests = 'precedence';
fb_lowFreqHz = 100;
fb_highFreqHz = 1400;

% Note copied from Braasch's code:
% minimum windowlength needs to be in order of binaural sluggishness for
% the model to operate properly. Needs sufficient length to perform 
% autocorrelation over both lead and lag.
prec_wSizeSec = 0.02;
prec_hSizeSec = 0.01;

par = genParStruct('fb_lowFreqHz',fb_lowFreqHz, ...
    'fb_highFreqHz',fb_highFreqHz, ...
    'prec_wSizeSec', prec_wSizeSec, ...
    'prec_hSizeSec', prec_hSizeSec);
 

%% PERFORM PROCESSING

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% PLOT RESULTS

% Input signals
dObj.plot([],[],'rangeSec', [0 0.05], 'bGray',1,'decimateRatio',3,'bSignal',1);
ylim([-0.8 0.8]);
legend('boxoff');

% Output ITD / ILD
figure;
plot(dObj.precedence{1}.Data(:))
title('Accumulated ITD') 
xlabel('Iteration steps / number of analyzed windows')
ylabel('ITD [ms]');

figure;
plot(dObj.precedence{2}.Data(:))
title('Accumulated ILD') 
xlabel('Iteration steps / number of analyzed windows')
ylabel('ILD [dB]');








