% This script tests the block-based ploting routine

clear 
close all


% Request and parameters for feature extraction
request = {'ratemap'};
p = [];

% Online processing parameters
chunkSize = 10000;    % Chunk size in samples

%% Signal
% Load a signal
load('TestBinauralCues');

% Only mono processing for this test
data = earSignals(:,2);
clear earSignals

% Number of chunks in the signal
n_chunks = ceil(size(data,1)/chunkSize);

% Zero-pad the signal for online vs. offline direct comparison
data = [data;zeros(n_chunks*chunkSize-size(data,1),1)];

%% Manager instantiation

% Create data objects
dObj = dataObject([],fsHz,10,1);

% Instantiate managers
mObj = manager(dObj);

% Add the request
s = mObj.addProcessor(request,p);


%% Processing

% Open a figure
h = figure;

% Online processing

for ii = 1:n_chunks
    
    % Read a new chunk of signal
    chunk = data((ii-1)*chunkSize+1:ii*chunkSize);
    
    % Request processing for the chunk
    mObj.processChunk(chunk,1);
    
    % Plot the computed representation
    s.plot(h);
    
end
