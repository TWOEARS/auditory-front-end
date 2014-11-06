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

% New sampling frequency
fsHzRef = 16E3;

% Resample
data = resample(data,fsHzRef,fsHz);

% Copy fs
fsHz = fsHzRef;

% Parameters
request = {'pitch'};
ac_wSizeSec   = 0.032;
ac_hSizeSec   = 0.016;
ac_clipAlpha  = 0.0;
ac_K          = 2;
pitchRangeHz  = [80 400];
confThresPerc = 0.7;
orderMedFilt  = 3;

% Parameters
p = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',16,'ihc_method','dau','ac_wSizeSec',ac_wSizeSec,'ac_hSizeSec',ac_hSizeSec,'ac_clipAlpha',ac_clipAlpha,'ac_K',ac_K); 


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
set(gca,'YLim',[80 400])
set(get(gca,'children'),'Marker','x')