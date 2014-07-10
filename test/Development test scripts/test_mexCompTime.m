% This script reports the differences in computation time when using mex
% files or not (for framing only at the moment).

clear all
close all

% Load a signal
load('TestBinauralCues');

% Parameters
request = 'crosscorrelation';

% Create two identical data objects
dObj1 = dataObject(earSignals,fsHz);
dObj2 = dataObject(earSignals,fsHz);

% Create empty manager (with mex)
mObj_mex = manager(dObj1);
mObj_nomex = manager(dObj2,[],0);

% Add the request
sOut_mex = mObj_mex.addProcessor(request);
sOut_nomex = mObj_nomex.addProcessor(request);

% Request and time processing
tic;
mObj_mex.processSignal;
t_mex = toc;
tic;
mObj_nomex.processSignal;
t_nomex = toc;

fprintf('Elapsed time: %fs (with mex), %fs (without mex).\n',t_mex,t_nomex)

