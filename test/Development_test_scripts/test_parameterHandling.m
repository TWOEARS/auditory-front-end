clear all
close all
clc

test_startup;

% Load a signal
load('TestBinauralCues');
data = earSignals;
fs = fsHz;
clear earSignals fsHz

%% Instantiate manager and data object

request = 'ild';
p = genParStruct('nERBs',1/2,'IHCMethod','dau');

% Create a data object
dObj = dataObject(data,fs);

% Create a manager
mObj = manager(dObj);

% Add requested processors
out1 = mObj.addProcessor(request,p);

%% Start processing

% Request processing
mObj.processSignal();

%% Plot results
out1.plot;
