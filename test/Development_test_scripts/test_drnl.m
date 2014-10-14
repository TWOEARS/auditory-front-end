% Test script to compare the output from TwoEars DRNL filterbank processor
% to the output from CASP 2008 version of implementation (Jepsen et al
% 2008)

clear all
close all
clc

%% Add paths
path = fileparts(mfilename('fullpath'));
% also added twoears-tools folder following the updates re circular buffers
% (assuming the folder is located inside the same folder where twoears-wp2 is) 
addpath(genpath([path filesep '..' filesep '..' filesep '..' filesep 'twoears-tools']))
run([path filesep '..' filesep '..' filesep 'src' filesep 'startWP2.m'])

%% test signal
% % 1. sinusoid with some onset/offset ramps
% % pasted from MAP1_14h test codes to potentially test against the MAP
% % implementation
% 
% sampleRate = 48000;             % trying to unify the input characteristics
% signalType= 'tones';
% toneFrequency= 10000;           % (Hz)
% duration = 0.5;                 % trying to unify the input characteristics
% beginSilence=0.050;
% endSilence=0.050;
% rampDuration=.005;              % raised cosine ramp (seconds)
% leveldBSPL= (-10:10:90);   
% 
% % define 20-ms onset sample after ramp completed (blue line)
% %  allowing 5-ms response delay
% onsetPTR1=round((rampDuration+ beginSilence +0.005)*sampleRate);
% onsetPTR2=round((rampDuration+ beginSilence +0.005 + 0.020)*sampleRate);
% 
% % last half 
% lastHalfPTR1=round((beginSilence+duration/2)*sampleRate);
% lastHalfPTR2=round((beginSilence+duration-rampDuration)*sampleRate);
% 
% dt=1/sampleRate; % seconds
% time=dt: dt: duration;
% inputSignal=sum(sin(2*pi*toneFrequency'*time), 1);
% amp=10.^(leveldBSPL/20)*28e-6;   % converts to Pascals (peak)
% inputSignal=amp'*inputSignal;
% % apply ramps
% % catch rampTime error
% if rampDuration>0.5*duration, rampDuration=duration/2; end
% rampTime=dt:dt:rampDuration;
% ramp=[0.5*(1+cos(2*pi*rampTime/(2*rampDuration)+pi)) ...
%     ones(1,length(time)-length(rampTime))];
% ramp_temp = repmat(ramp, [length(leveldBSPL), 1]);
% 
% inputSignal=inputSignal.*ramp_temp;
% ramp_temp=fliplr(ramp_temp);
% inputSignal=inputSignal.*ramp_temp;
% % add silence
% intialSilence= zeros(1,round(beginSilence/dt));
% finalSilence= zeros(1,round(endSilence/dt));
% inputSignal= [repmat(intialSilence, [length(leveldBSPL), 1]) inputSignal repmat(finalSilence, [length(leveldBSPL), 1])];

% % 2. input signal used in WP2 test script
% load('TestBinauralCues');

% 3. input / output in CASP 2008 test script
% the data file contains input (x.wav), the stapes output (xStapes), the
% DRNL parameters (BM structure), and the model output (IntRep structure)
load('CASP_data'); 

%% Instantiate manager and data object
request = 'drnl';

% % For testing against MAP examples
% dObj = dataObject(inputSignal(2,:), fs);
% mObj = manager(dObj);               % Manager instance
% param_struct = genParStruct('drnl_CF', [500 1000 5000 10000]);
% out = mObj.addProcessor(request, param_struct);

% For testing against CASP2008
% comparison to CASP output needs stapes output as the input to DRNL
% filterbank - so use xStapes instead of x for dataObject
dObj = dataObject(xStapes, fs);
mObj = manager(dObj);               % Manager instance
% BM.CenterFreqs is a list of Characteristic Frequencies as the input to
% DRNL processor
param_struct = genParStruct('drnl_CF', BM.CenterFreqs);
out = mObj.addProcessor(request, param_struct);

%% Request processing
mObj.processSignal();

%% Compare results - to CASP 2008 output: IntRep.BM
duration = length(xStapes)/fs;
dt=1/fs; % seconds
time=dt: dt: duration;

% dObj.drnl.Data vs IntRep.BM
diff = (abs(dObj.drnl{1}.Data(:) - IntRep.BM)+eps).';
figure;
imagesc(dObj.drnl{1}.Data(:).'); colorbar;
figure;
imagesc(IntRep.BM.'); colorbar;
figure;
imagesc(20*log10(diff)); colorbar;
set(gca,'XTick', [round(size(dObj.drnl{1}.Data(:).', 2)/2) size(dObj.drnl{1}.Data(:).', 2)]);
set(gca,'XTickLabel', {time(round(size(dObj.drnl{1}.Data(:).', 2)/2)), time(size(dObj.drnl{1}.Data(:).', 2))});
set(gca,'YTick', [1 round(size(dObj.drnl{1}.Data(:).', 1)/2) size(dObj.drnl{1}.Data(:).', 1)]);
set(gca,'YTickLabel', {BM.CenterFreqs(1), BM.CenterFreqs(round(size(dObj.drnl{1}.Data(:).', 1)/2)), BM.CenterFreqs(size(dObj.drnl{1}.Data(:).', 1))});
xlabel('Time [sec]');
ylabel('CF [Hz]');
title('Error in BM output between drnlProc and CASP2008');


% dObj.drnl{1}.plot;      % this needs revising - inside TImeFrequencySignal



