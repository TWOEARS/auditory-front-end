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
run([path filesep '..' filesep '..' filesep 'startAuditoryFrontEnd.m'])

%% test signal
% % 2. input signal used in WP2 test script
% load('TestBinauralCues');

% 3. input / output in CASP 2008 test script
% the data file contains input (x.wav), the stapes output (xStapes), the
% DRNL parameters (BM structure), and the model output (IntRep structure)
load('CASP_data'); 
% Create parameter structure specifying Characteristic Frequencies as
% defined in CASP2008 script
param_struct = genParStruct('drnl_cfHz', BM.CenterFreqs);

%% Instantiate manager and data object
request = 'drnl';

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

%% Compare results - to CASP 2008 output: IntRep.BM
duration = length(xStapes)/fs;
dt=1/fs; % seconds
time=dt: dt: duration;

% dObj.drnl.Data vs IntRep.BM
diff = (abs(dObj.drnl{1}.Data(:) - IntRep.BM)+eps).';
figure;
imagesc(dObj.drnl{1}.Data(:).'); colorbar;
title('BM output: drnlProc');
figure;
imagesc(IntRep.BM.'); colorbar;
title('BM output: CASP2008');
figure;
imagesc(20*log10(diff)); colorbar;
set(gca,'XTick', [round(size(dObj.drnl{1}.Data(:).', 2)/2) size(dObj.drnl{1}.Data(:).', 2)]);
set(gca,'XTickLabel', {time(round(size(dObj.drnl{1}.Data(:).', 2)/2)), time(size(dObj.drnl{1}.Data(:).', 2))});
set(gca,'YTick', [1 round(size(dObj.drnl{1}.Data(:).', 1)/2) size(dObj.drnl{1}.Data(:).', 1)]);
set(gca,'YTickLabel', {BM.CenterFreqs(1), BM.CenterFreqs(round(size(dObj.drnl{1}.Data(:).', 1)/2)), BM.CenterFreqs(size(dObj.drnl{1}.Data(:).', 1))});
xlabel('Time [sec]');
ylabel('CF [Hz]');
title('Error in BM output between drnlProc and CASP2008');
