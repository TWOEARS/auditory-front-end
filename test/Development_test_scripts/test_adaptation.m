% Test script to compare the output from TwoEars adaptation processor
% to the output from CASP 2008 (Jepsen et al. 2008) / PEMO versions of implementation 
% 
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
% % 1. input signal used in WP2 test script ------------------------------
% load('TestBinauralCues');
% % ----------------------------------------------------------------------

% 2. input / output in CASP 2008 test script ---------------------------
% the data file contains input (x.wav), the stapes output (xStapes), the
% DRNL parameters (BM structure), and the model output (IntRep structure)
load('CASP_data2');       % IHC stage in CASP uses 2ND ORDER LPF here
% Create parameter structure specifying Characteristic Frequencies as
% defined in CASP2008 script
param_struct = genParStruct('drnl_cf', BM.CenterFreqs, 'adpt_lim', 0);
% ----------------------------------------------------------------------

%% Instantiate manager and data object
request = 'adaptation';

% For testing against CASP2008
% comparison to CASP output needs stapes output as the input to DRNL
% filterbank - so use xStapes instead of x for dataObject
dObj = dataObject(xStapes, fs);
mObj = manager(dObj);               % Manager instance
% BM.CenterFreqs is a list of Characteristic Frequencies as the input to
% DRNL processor
out = mObj.addProcessor(request, param_struct);

%% Request processing
mObj.processSignal();

%% Compare results - to CASP 2008 output: IntRep.adapt
duration = length(xStapes)/fs;
dt=1/fs; % seconds
time=dt: dt: duration;

% dObj.drnl.Data vs IntRep.BM
diff = (abs(dObj.adaptation{1}.Data(:) - IntRep.adapt)+eps).';
figure;
imagesc(dObj.adaptation{1}.Data(:).'); colorbar;
title('adaptationProc data');
figure;
imagesc(IntRep.adapt.'); colorbar;
title('CASP2008 data');
figure;
imagesc(20*log10(diff)); colorbar;
set(gca,'XTick', [round(size(dObj.adaptation{1}.Data(:).', 2)/2) size(dObj.adaptation{1}.Data(:).', 2)]);
set(gca,'XTickLabel', {time(round(size(dObj.adaptation{1}.Data(:).', 2)/2)), time(size(dObj.adaptation{1}.Data(:).', 2))});
set(gca,'YTick', [1 round(size(dObj.adaptation{1}.Data(:).', 1)/2) size(dObj.adaptation{1}.Data(:).', 1)]);
set(gca,'YTickLabel', {BM.CenterFreqs(1), BM.CenterFreqs(round(size(dObj.adaptation{1}.Data(:).', 1)/2)), BM.CenterFreqs(size(dObj.adaptation{1}.Data(:).', 1))});
xlabel('Time [sec]');
ylabel('CF [Hz]');
title('Error in adaptation loop output between drnlProc and CASP2008');


% dObj.drnl{1}.plot;      % this needs revising - inside TImeFrequencySignal



