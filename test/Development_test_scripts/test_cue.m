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
request = {'innerhaircell'};
% p = genParStruct('nChannels',15);
p = genParStruct('drnl_CF', ...     % use this when testing with drnlProc
    1.0e+03 * [0.0800 0.1616 0.2648 0.3952 0.5601 0.7686 1.0321 1.3653 1.7866 ...
    2.3191 2.9924 3.8436 4.9197 6.2801 8.0000]); 

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
