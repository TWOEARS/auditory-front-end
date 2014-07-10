clear all
close all
clc

% This script tests the capability of the manager to extract a specific
% cue

% Add path
% path = fileparts(mfilename('fullpath')); 
% run([path filesep '..' filesep '..' filesep 'src' filesep 'startWP2.m'])

% Load a binaural signal
load('TestBinauralCues');

% Parameters
request = 'ic_xcorr';

% Create a data object
dObj = dataObject(earSignals,fsHz);

% Create empty manager
mObj = manager(dObj);

% Add the request
sOut = mObj.addProcessor(request);

% Request processing
mObj.processSignal;

sOut.plot;
