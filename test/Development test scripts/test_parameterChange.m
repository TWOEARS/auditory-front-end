clear all
close all
clc

% INCOMPLETE ATM

%% Load a signal

% Add paths
path = fileparts(mfilename('fullpath')); 
run([path filesep '..' filesep '..' filesep 'src' filesep 'startWP2.m'])

% Load a signal
load('TestBinauralCues');
data = earSignals;
fs = fsHz;
clear earSignals fsHz

%% Instantiate manager and data object

requests = {'ild','itd_xcorr','ratemap_magnitude','ratemap_power'};

% Create a data object
dObj = dataObject(data,fs);

% Create a manager
mObj = manager(dObj);

% Add requested processors
out = cell(size(requests));

for ii = 1:size(requests,2)
    out{ii} = mObj.addProcessor(requests{ii});
end


%% Start processing

% Request processing
mObj.processSignal();

%% Plot results
for ii = 1:size(out,2)
    if size(out{ii},2) == 1
        out{ii}.plot
    elseif size(out{ii},2) == 2
        % Plot only left channel
        out{ii}{1}.plot
    end
end