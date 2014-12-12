% This script tests the capability of the manager to extract a specific
% cue

% clear 
close all

% test_startup;

% Test on monoral or binaural signal
do_stereo = 0;

% Load a signal
load('TestBinauralCues');

if ~do_stereo
    data = earSignals(1:62E3,2);     % Right channel has higher energy
else
    data = earSignals;
end
clear earSignals

% Parameters
request = {'innerhaircell'};
p = [];%genParStruct('pp_bNormalizeRMS',1);


% Create a data object
dObj = dataObject(data,fsHz);

% Create empty manager
mObj = manager(dObj);

% Add the request
sOut = mObj.addProcessor(request,p);

% Request processing
tic
mObj.processSignal;
t = toc;
fprintf('Computation time to signal duration ratio : %d\n',t/(size(data,1)/fsHz))

% Plot output
if iscell(sOut)
    sOut{1}.plot;
else
    sOut.plot;
end