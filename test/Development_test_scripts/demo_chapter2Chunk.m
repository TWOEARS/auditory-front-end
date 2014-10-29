clear all
close all

% Basic script used throughout chapter 2 of deliverable 2.2
% Using echo for copy/pasting to deliverable text

% Loading a signal
load('TestBinauralCues');
sIn = earSignals;
clear earSignals

L = size(sIn,1);    % Number of samples in the input signal

% Boundaries for arbitrary chunk size
chunkSizeMin = 100;
chunkSizeMax = 20000;

% Instantiation of data and manager objects
dataObj = dataObject([],fsHz,10,1);
managerObj = manager(dataObj);

% Place a request
sOut = managerObj.addProcessor('ild');

% Initialize current chunk indexes
chunkStart = 0;
chunkStop = 1;

% Simulate a chunk-based aquisition of the input
while chunkStart < L - chunkSizeMin
    
    % Generate new chunk boundaries
    chunkStart = chunkStop + 1;
    chunkStop = chunkStart + chunkSizeMin + ...
                randsample(chunkSizeMax-chunkSizeMin,1);
            
    % Limit the end of the chunk to the end of the signal
    chunkStop = min(chunkStop,L);
            
    % Request the processing of the chunk
    managerObj.processChunk(sIn(chunkStart:chunkStop,:),1);
    
end

% Comparison with offline processing
dataObjOff = dataObject(sIn,fsHz);
managerObjOff = manager(dataObj);
sOutOff = managerObjOff.addProcessor('ild');
managerObjOff.processSignal;

% Plot the difference between the two representations
figure,imagesc(sOut.Data(:)-sOutOff.Data(:)),colorbar