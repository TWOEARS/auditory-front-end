clear all
close all

%% Load a signal

% Add paths
path = fileparts(mfilename('fullpath')); 
run([path filesep '..' filesep '..' filesep 'src' filesep 'startWP2.m'])

% Load a signal
load('TestBinauralCues');

%% Instantiate manager and data object

% Request a gammatone filtering...
request = 'gammatone';
dObj = dataObject(earSignals,fsHz); % Data object
mObj = manager(dObj);               % Manager instance

% In several different ways
% p1 = genParStruct('f_low',80,'f_high',8000,'nERBs',1);      % Standard way, frequency range and distance between channels
p2 = genParStruct('f_low',80,'f_high',8000,'nChannels',20); % Frequency range and number of channels
p3 = genParStruct('cfHz',[50 100 200 400 800 1600 3200]);   % Entire vector of center frequencies

% Add requested processors
% out1 = mObj.addProcessor(request,p1);
out2 = mObj.addProcessor(request,p2);
out3 = mObj.addProcessor(request,p3);

%% Start processing

% Request processing
mObj.processSignal();

%% Display output signal properties
fprintf('First filterbank has center frequencies: %s\n',mat2str(out1{1}.cfHz))
fprintf('Second filterbank has center frequencies: %s\n',mat2str(out2{1}.cfHz))
fprintf('Third filterbank has center frequencies: %s\n',mat2str(out3{1}.cfHz))


