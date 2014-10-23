clear;
close all
clc


%% Load a signal

% Add paths
path = fileparts(mfilename('fullpath')); 
run([path filesep '..' filesep 'src' filesep 'startAuditoryFrontEnd.m'])

addpath(['Test_signals',filesep]);

% Load a signal
load('TestBinauralCues');

% Ear signals
data = fliplr(earSignals);

fs = fsHz;
clear earSignals fsHz


%% Perform AGC
% 
% 
% Integration constant in seconds
timeSec = 500E-3;

% Apply AGC to all channels independently
agc(data,fs,timeSec,false);

% Preserve level differences across channels
agc(data,fs,timeSec,true);