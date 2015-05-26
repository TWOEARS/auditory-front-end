% This is a test script to investigate Matlab's event-based programming

% clear all
close all

% Load a signal
load('TestBinauralCues');
data = earSignals(1:62E3,:);   

% Parameters
request = {'itd'};
p = [];

% Create a data object
dObj = dataObject(data,fsHz);

% Create empty manager
mObj = manager(dObj);

% Add the request
sOut = mObj.addProcessor(request,p);

% Remove cross-correlation processor
mObj.Processors{4}.remove;
mObj.cleanup;

echo on
mObj.Processors
echo off