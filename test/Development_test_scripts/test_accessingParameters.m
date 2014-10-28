% This script tests the various methods to access the parameter values that
% were used for the computation of some representations

clear all
close all

test_startup;

% Test on monoral or binaural signal
do_stereo = 1;

% Load a signal
load('TestBinauralCues');
data = earSignals;
clear earSignals

% Parameters
request1 = 'itd_xcorr';
p1 = genParStruct('f_low',80,'f_high',8000,'nChannels',30);

request2 = 'ild';
p2 = genParStruct('f_low',80,'f_high',8000,'nERBs',1/2);


% Instantiation and processing
dObj = dataObject(data,fsHz);           % Create a data object
mObj = manager(dObj);                   % Create empty manager
sOut = mObj.addProcessor(request1,p1);  % Add first request
mObj.addProcessor(request2,p2);         % Add second request
mObj.processSignal;                     % Request processing

fprintf('\n')

echo on
% Get the parameters of the requested signal...

% ... via its processor (has to be known)
mObj.Processors{5,1}.getCurrentParameters

% ... or directly from the signal handle 
sOut.getParameters(mObj)

% Summary of all parameters used for the computation of all signals:
p = dObj.getParameterSummary(mObj);

% It shows that two different filterbanks and IHC representation exist,
% e.g.:
p.gammatone

% Though it stores which of these were used for dependent representations,
% e.g.:
p.ild



echo off
