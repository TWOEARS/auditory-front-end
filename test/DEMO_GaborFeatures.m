clear
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
requests = {'gabor'};

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
                   'rm_wSizeSec',rm_wSizeSec,'rm_hSizeSec',rm_wStepSec,'rm_scaling','power',...
                   'rm_decaySec',rm_decaySec); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


% Plot the results
dObj.ratemap{1}.plot
dObj.gabor{1}.plot


if 0
    fig2LaTeX('Gabor_01',1,16);
    fig2LaTeX('Gabor_02',2,16);
end