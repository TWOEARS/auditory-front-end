clear all
close all

% This script is for testing the behavior of the hasProcessor method of the
% manager class

% Load a signal
load([pwd,filesep,'WP2_Data',filesep,'TestBinauralCues']);

% Multiple requests
request1 = 'innerhaircell';
p1 = struct;

request2 = 'innerhaircell';
p2 = struct;
p2.nERBs = 1/3;


% Instantiate data and manager objects
dObj = dataObject(earSignals(:,2),fsHz);    % Create a data object based on this signal
mObj = manager(dObj);                    % Instantiate an empty manager

% Add requests
out1 = mObj.addProcessor(request1,p1);
out2 = mObj.addProcessor(request2,p2);

% Request the processing
mObj.processSignal


% Get full parameter structures
p1.fs = fsHz;
p1full = parseParameters(p1);
p2.fs = fsHz;
p2full = parseParameters(p2);

echo on
% Find an IHC processor with parameters p2:

h = mObj.hasProcessor('IHCenvelopeProc',p2full);


% There are two IHC Processors (3 & 6), both have the same parameters

mObj.Processors{3}
mObj.Processors{6}


% But only one has its dependencies with the right set of parameters

h == mObj.Processors{3}
h == mObj.Processors{6}

echo off


