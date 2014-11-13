clear;
close all
clc


%% LOAD SIGNAL
% 
% 
% Load a signal
load('AFE_earSignals_16kHz');

% Create a data object based on parts of the ear signals
dObj = dataObject(earSignals(1:20E3,:),fsHz);


%% PLACE REQUEST AND CONTROL PARAMETERS
% 
% 
% Request gabor features  
requests = {'gabor'};


% Following the ETSI standard
nChannels  = [23];
lowFreqHz  = 124;
highFreqHz = 3657;

% Window size in seconds
rm_wSizeSec = 25E-3;
rm_wStepSec = 10E-3; % DO NOT CHANGE!!!
rm_decaySec = 8E-3;

% Parameters
par = genParStruct('fb_lowFreqHz',lowFreqHz,'fb_highFreqHz',highFreqHz,'fb_nChannels',nChannels,...
                   'rm_wSizeSec',rm_wSizeSec,'rm_hSizeSec',rm_wStepSec,'rm_scaling','power',...
                   'rm_decaySec',rm_decaySec); 


%% PERFORM PROCESSING
% 
% 
% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();

% Plot the results
dObj.ratemap{1}.plot
dObj.gabor{1}.plot

 
if 0
    fig2LaTeX('Gabor_01',1,16);
    fig2LaTeX('Gabor_02',2,16);
end

