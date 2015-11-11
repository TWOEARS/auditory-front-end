clear;
close all
clc


%% LOAD SIGNAL

fsHz=48000;             % Sampling Frequency [Hz]
ISI=[3];                % Inter-stimulus Interval [ms]
Ratio=[0];              % lead/lag level ratio [dB]
StimDuration=200;       % stimulus duration [ms]

% create test stimulus (binaural)
% usage: STIMULUS(Fs,mode,len,f,bw,itd1,itd2,isi,at,dc)
% this function is copied from Braasch's model into AFE src/Tools
x = stimulusBraasch(fsHz, 2, 400, 500, 800, 0.4, -0.4, 3, 20, 20, 0,db2amp(0));

% Create a data object based on parts of the right ear signal
dObj = dataObject(x, fsHz);


%% PLACE REQUEST AND CONTROL PARAMETERS

requests = 'precedence';
fb_lowFreqHz = 100;
fb_highFreqHz = 1400;

% Note from Braasch:
% minimum windowlength needs to be in order of binaural sluggishness for
% the model to operate properly (now set to 1024 tabs). Needs sufficient
% length to perform autocorrelation over both lead and lag.
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








