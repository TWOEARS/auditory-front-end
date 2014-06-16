clear all
close all

load([pwd,filesep,'WP2_Data',filesep,'TestBinauralCues']);

request = 'innerhaircell';

% Change a parameter
p = struct;
p.nERBs = 1/3;
p.IHCMethod = 'hilbert';

% Instantiate data and manager objects
dObj = dataObject(earSignals(:,2),fsHz);    % Create a data object based on this signal
mObj = manager([],dObj);                    % Instantiate an empty manager

% Add the requested processor
ihc = mObj.addProcessor(request,p);

mObj.processSignal
% dObj.innerhaircell{1}.plot;

ihc.plot

