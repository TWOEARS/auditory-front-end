clear all
close all
clc

% INCOMPLETE ATM

%% Load a signal

% Add paths
path = fileparts(mfilename('fullpath')); 
run([path filesep '..' filesep '..' filesep 'src' filesep 'startWP2.m'])

% Load a signal
load('TestBinauralCues');
data = earSignals;
fs = fsHz;
clear earSignals fsHz

%% Instantiate manager and data object

request1 = 'ild';

request2 = 'ild';
p2 = struct;
p2.fs = fs;
p2.nERBs = 1/3;

request3 = 'ild';
p3 = struct;
p3.fs = fs;
p3.ild_wSizeSec = 50E-3;
p3.ild_hSizeSec = 25E-3;

% Create a data object
dObj = dataObject(data,fs);

% Create a manager
mObj = manager(dObj);

% Add requested processors
out1 = mObj.addProcessor(request1);
out2 = mObj.addProcessor(request2,p2);
out3 = mObj.addProcessor(request3,p3);

%% Start processing

% Request processing
mObj.processSignal();

%% Plot results
out1.plot;
out2.plot;
out3.plot;

mObj.Processors