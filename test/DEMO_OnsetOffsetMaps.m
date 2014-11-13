clear;
close all
clc


% Load a signal
load('TestBinauralCues');

% Take right ear signal
data = earSignals(1:62E3,2);     

% New sampling frequency
fsHzRef = 16E3;

% Resample
data = resample(data,fsHzRef,fsHz);

% Copy fs
fsHz = fsHzRef;

% Request ratemap    
requests = {'onset_map' 'offset_map'};

% Minimum ratemap level in dB below which onsets or offsets are not considered
minRatemapLeveldB = -80;

% Ratemap settings
rm_wSizeSec = 20E-3;
rm_hSizeSec = 10E-3;
rm_decaySec = 8E-3;
nChannels   = 64;

% Onset parameters
minOnsetStrengthdB  = 3;
minOnsetSize        = 5;
fuseOnsetsWithinSec = 30E-3;

% Offset parameters
minOffsetStrengthdB  = 3;
minOffsetSize        = 5;
fuseOffsetsWithinSec = 30E-3;

% Parameters
par = genParStruct('fb_lowFreqHz',80,'fb_highFreqHz',8000,'fb_nChannels',nChannels,'ihc_method','dau','rm_decaySec',rm_decaySec,'rm_wSizeSec',rm_wSizeSec,'rm_hSizeSec',rm_hSizeSec,'ons_minValuedB',minRatemapLeveldB,'ofs_minValuedB',minRatemapLeveldB); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj);
mObj.addProcessor(requests,par);

% Request processing
mObj.processSignal();

%% Plot onset and offset maps

% Plot the onset
h = dObj.onset_map{1}.plot;
hold on

% Superimposed the offset (in white)
p = genParStruct('binaryMaskColor',[1 1 1]);    % White mask
dObj.offset_map{1}.plot(h,p,1);

% Replace the title
title('Onset (black) and offset (white) maps')

% Find the spacing for the y-axis which evenly divides the y-axis
% set(gca,'ytick',linspace(1,nChannels,nYLabels));
% set(gca,'yticklabel',round(interp1(1:nChannels,dObj.onset_strength{1}.cfHz,linspace(1,nChannels,nYLabels))));

