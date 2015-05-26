% This is a test script to investigate Matlab's event-based programming'

clear all
close all

% Memory watching tool
% C:\Users\rjdb\Documents\MATLAB\Parallel computing seminar\01_Techniques_for_Speeding_up_Matlab\03_Memory

% Load a signal
load('TestBinauralCues');
data = earSignals(1:62E3,:);     % Right channel has higher energy

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
