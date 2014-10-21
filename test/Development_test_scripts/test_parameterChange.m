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

% First request, with default parameters
request1 = 'ild';

% Second request, with added non-default parameters
request2 = 'itd_xcorr';
p2 = genParStruct('f_high',4000,'nERBs',1/2,'cc_wname','hamming','cc_wSizeSec',50E-3,'cc_hSizeSec',25E-3);

% Create a data object
dObj = dataObject(data,fs);

% Create a manager
mObj = manager(dObj);

% Add requested processors
out1 = mObj.addProcessor(request1);
out2 = mObj.addProcessor(request2,p2);

%% Start processing

% Request processing
mObj.processSignal();

%% Plot results
out1.plot;
out2.plot;

% Visualize the instantiated processors
mObj.Processors
