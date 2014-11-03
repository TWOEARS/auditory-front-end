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

% The level conversion and outer-middle ear filtering are added for DRNL
% To compare the DRNL output directly corresponding to the gammatone
% output, the input to both processors needs to be converted to the stapes output. 

% Obtain the level convention (what dB SPL corresponds to signal level of
% 1)
dboffset=dbspl(1);

% Scale signal such that level 1 corresponds to 100 dB SPL
dataScaled=gaindb(data, dboffset-100);

% Introduce outer/middle ear filter (imported tools from AMT)
oe_fir = headphonefilter(fsHz);
me_fir = middleearfilter(fsHz,'jepsenmiddleear');

% Convert input to stapes output, through outer-middle ear filters
dataMiddleEar = filter(oe_fir, 1, dataScaled);
dataStapes = filter(me_fir, 1, dataMiddleEar);

% Request DRNL    
requests = {'drnl'};

% Parameters
par = genParStruct('drnl_lowFreqHz',80,'drnl_highFreqHz',8000,'drnl_nChannels',16); 

% Create a data object - here use dataStapes (stapes output, velocity)
dObj = dataObject(dataStapes,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Plot DRNL response
% 
% 
% Basilar membrane output
bm   = [dObj.drnl{1}.Data(:,:)];
fHz  = dObj.drnl{1}.cfHz;
tSec = (1:size(bm,1))/fsHz;

zoom  = [];
bNorm = [];


figure;
plot(tSec(1:3:end),data(1:3:end));
xlabel('Time (s)')
ylabel('Amplitude')
xlim([tSec(1) tSec(end)]);
ylim([-1 1])

figure;

waveplot(bm(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);
ylabel('Characteristic frequency (Hz)');


%% To compare the above result to the gammatone output 
%% (using the same stapes velocity as the input)

% Request ratemap    
requests = {'ratemap_power'};

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',16); 

% Create a data object - here use dataStapes (stapes output, velocity)
dObj_gt = dataObject(dataStapes,fsHz);

% Create a manager
mObj_gt = manager(dObj_gt,requests,par);

% Request processing
mObj_gt.processSignal();


%% Plot Gammatone response
% 
% 
% Basilar membrane output
bm_gt   = [dObj_gt.gammatone{1}.Data(:,:)];
fHz  = dObj_gt.gammatone{1}.cfHz;
tSec = (1:size(bm,1))/fsHz;

zoom  = [];
bNorm = [];

figure;
waveplot(bm_gt(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);

