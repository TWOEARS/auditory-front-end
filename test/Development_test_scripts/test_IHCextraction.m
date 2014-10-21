% This script tests all possible methods for inner hair-cell envelope
% extraction

% clear all
close all

test_startup;

%% Load a mono signal
path = fileparts(mfilename('fullpath'));
load([path filesep '..' filesep 'Test_signals' filesep 'TestBinauralCues']);
data = earSignals(:,2);
clear earSignals

%% Requests and parameters

request = 'innerhaircell';

% Get all the implemented inner hair-cell models
p = {genParStruct('IHCMethod','none') ...
    genParStruct('IHCMethod','halfwave') ...
    genParStruct('IHCMethod','fullwave') ...
    genParStruct('IHCMethod','square') ...
    genParStruct('IHCMethod','hilbert') ...
    genParStruct('IHCMethod','joergensen') ...
    genParStruct('IHCMethod','dau') ...
    genParStruct('IHCMethod','breebart') ...
    genParStruct('IHCMethod','bernstein')};

% Replicate the request 
request = repmat({request},size(p));

%% Instantiate manager and data object, add requests, and process
dObj = dataObject(data,fsHz);
mObj = manager(dObj);

% Add the requests
mObj.addProcessor(request,p);

% Process the signal
mObj.processSignal;

%% Plot the obtained representations

h = zeros(size(p));

% Qucik and dirty figure positioning
posx = repmat([0.1 0.4 0.7],1,3)';
posy = repmat([0.1 0.4 0.7],3,1); posy = posy(:);

for ii = 1:size(dObj.innerhaircell,1)
    h(ii) = dObj.innerhaircell{ii}.plot;
    set(h(ii),'Units','normalized','Position',[posx(ii) posy(ii) 0.2 0.2]);
    
    % Change the titles to the method used
    title(p{ii}.IHCMethod)
end


