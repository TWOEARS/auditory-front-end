% This script tests the getCurrentParameters method of the processors

clear all
close all

% Add path
% path = fileparts(mfilename('fullpath')); 
% run([path filesep '..' filesep '..' filesep 'src' filesep 'startWP2.m'])

% Test on monoral or binaural signal
do_stereo = 1;

% Load a signal
load('TestBinauralCues');
data = earSignals;
clear earSignals

% Parameters
request = 'itd_xcorr';
p = genParStruct('f_low',80,'f_high',8000,'nChannels',30);

% Instantiation and processing
dObj = dataObject(data,fsHz);           % Create a data object
mObj = manager(dObj);                   % Create empty manager
sOut = mObj.addProcessor(request,p);    % Add the request
mObj.processSignal;                     % Request processing

% Get the parameters of the requested signal...

% ... via its processor (has to be known)
mObj.Processors{5,1}.getCurrentParameters

% ... or directly from the signal handle (coming soon)
sOut.getParameters(mObj)
