% This is a test script to investigate Matlab's event-based programming'

clear all
close all


% Load a signal
load('TestBinauralCues');
data = earSignals(1:62E3,2);     % Right channel has higher energy

% Parameters
request = {'itd'};
p = [];

% Create a data object
dObj = dataObject(data,fsHz);

% Create empty manager
mObj = manager(dObj);

% Add the request
sOut = mObj.addProcessor(request,p);

% Modify a parameter
fprintf('\n')
disp('Modifying the pre-processor should trigger a reset for all dependent processor:')
mObj.Processors{1}.modifyParameter()

fprintf('\n')
disp('Modifying the inner hair-cell processor should only trigger processors depending on it:')
mObj.Processors{3}.modifyParameter()