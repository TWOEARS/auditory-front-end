% This script tests the capability of the manager to extract a specific
% cue

clear 
close all


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
request = {'amsFeature'};
p = genParStruct('ams_fbType','lin');


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
fprintf('Computation time to signal duration ratio : %3d%%\n', ...
        round(t/(size(data,1)/fsHz)*100))

% Plot output
sOut{1}.plot;
if size(sOut,2) == 2
    sOut{2}.plot;
end
