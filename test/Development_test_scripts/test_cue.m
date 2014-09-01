% This script tests the capability of the manager to extract a specific
% cue

clear 
close all

% Add path
% path = fileparts(mfilename('fullpath')); 
% run([path filesep '..' filesep '..' filesep 'src' filesep 'startWP2.m'])

% Test on monoral or binaural signal
do_stereo = 1;

% Load a signal
load('TestBinauralCues');

if ~do_stereo
    data = earSignals(:,2);     % Right channel has higher energy
else
    data = earSignals;
end
clear earSignals

% Parameters
request = 'modulation';
p = [];

% Create a data object
dObj = dataObject(data,fsHz);

% Create empty manager
mObj = manager(dObj);

% Add the request
sOut = mObj.addProcessor(request,p);

% Request processing
mObj.processSignal;

% Plot output
if iscell(sOut)
    sOut{1}.plot;
else
    sOut.plot;
end
