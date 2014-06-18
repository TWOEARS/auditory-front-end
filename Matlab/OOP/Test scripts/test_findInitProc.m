clear all
close all

% This script is for testing the behavior of the findInitProc method of the
% manager class

% Load a signal
load([pwd,filesep,'WP2_Data',filesep,'TestBinauralCues']);

% Original request with default parameters
request = 'crosscorrelation';

% Instantiate data and manager objects
dObj = dataObject(earSignals,fsHz);     % Create a data object based on this signal
mObj = manager(dObj,request);           % Instantiate a manager for the original request

% Ask which processor should be taken as a starting point for different
% scenarios:
% 1- We change the frequency resolution of the filterbank
    new_request1 = 'innerhaircell';
    p1 = struct;
    p1.nERBs = 1/3;   
    disp('Changing the resolution of the filterbank implies going back to the time domain signal:')
    init_proc1 = mObj.findInitProc(new_request1,p1)
    
% 2- We request ITDs based on the same original parameter
    new_request2 = 'itd_xcorr';
    p2 = struct;
    disp('Computing ITDs with default parameter can be started from the existing cross-correlation processor:')
    init_proc2 = mObj.findInitProc(new_request2,p2)
    
% 3- We request ITDs but using a different window shape
    new_request3 = 'itd_xcorr';
    p3 = struct;
    p3.cc_wname = 'hann';
    disp('However, ITDs with e.g., a different window shape, needs to be recomputed from the inner hair-cell envelope:')
    init_proc3 = mObj.findInitProc(new_request3,p3)
    
