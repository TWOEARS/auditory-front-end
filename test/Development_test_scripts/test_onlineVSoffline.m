% This script tests the results obtained for online vs. offline processing
% for a given feature

clear 
% close all

% Request and parameters for feature extraction
% request = {'modulation'};
request = {'innerhaircell'};
p = [];
% p = genParStruct('IHCMethod','breebart','am_type','filter');


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
dObj_off = dataObject(data,fsHz);
dObj_on = dataObject(data,fsHz);

% Instantiate managers
mObj_off = manager(dObj_off);
mObj_on = manager(dObj_on);

% Add the request
s_off = mObj_off.addProcessor(request,p);
s_on = mObj_on.addProcessor(request,p);

fprintf(['Online performance of ' signal2procName(s_off.Name) ':\n'])

%% Processing

% Offline processing
tic;mObj_off.processSignal;t_off = toc;

% Online processing
tic
for ii = 1:n_chunks
    
    % Read a new chunk of signal
    chunk = data((ii-1)*chunkSize+1:ii*chunkSize);
    
    % Request processing for the chunk
    mObj_on.processChunk(chunk,1);
    
end
t_on = toc;

%% Results comparison

% Normalized RMS error
RMS = 20*log10(norm(reshape(s_on.Data(:),[],1)-reshape(s_off.Data(:),[],1),2)/norm(reshape(s_off.Data(:),[],1),2));
fprintf('\tNormalized RMS error in offline vs. online processing: %d dB\n',round(RMS))

% Timing
fprintf('\tComputation time for online: %f s (%d%% of signal duration)\n',t_on,round(100*t_on*fsHz/size(data,1)))
fprintf('\tComputation time for offline: %f s (%d%% of signal duration)\n',t_off,round(100*t_off*fsHz/size(data,1)))

% Try and plot the difference
% Try to add your own case to the loop if it is missing
switch s_off.Name
    case 'modulation'
        delta = ModulationSignal(s_off.FsHz,dObj_on.bufferSize_s,'modulation',s_off.cfHz,s_off.modCfHz,['''' mObj_on.Processors{4,1}.filterType '''-based modulation: online vs offline'],s_off.Data(:)-s_on.Data(:)+eps);
        delta.plot;
        colorbar
        

    case {'innerhaircell' 'gammatone' 'onset_strength' 'offset_strength' 'ratemap_magnitude' ...
            'ratemap_power'}
        figure,imagesc(20*log10(abs(s_off.Data(:)-s_on.Data(:))+eps).')
        colorbar
        title(['Chunk vs signal-based, ' s_off.Name])
        
    otherwise
        fprintf('\tCould not print the online vs. offline data difference\n')
end