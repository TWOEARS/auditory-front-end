clear;
% close all
clc

% Load a signal
load('TestBinauralCues');

% Take right ear signal
earSignal = earSignals(:,2);

% Use pink noise to add to the input signal (Brown et al., JASA 2010)
pinkNoise = pinknoise(length(earSignal));

% Band pass filter - this needs Signal Processing Toolbox
bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
         'HalfPowerFrequency1',100,'HalfPowerFrequency2',22000, ...
         'SampleRate',fsHz);
pinkNoiseFiltered = filter(bpFilt,pinkNoise);

SNR = 5;

% Set pink noise amplitude SNR dB below the ear signal
pinkNoiseScaled = setdbspl(pinkNoiseFiltered, dbspl(earSignal)-SNR);

% Add to create noisy speech signal
earSignalNoisy = earSignal+pinkNoiseScaled.';

% Same resampling procedure as in other DEMO scripts
data = earSignalNoisy(1:62E3);     

% New sampling frequency
fsHzRef = 16E3;

% Resample
data = resample(data,fsHzRef,fsHz);

% Copy fs
fsHz = fsHzRef;

% The level conversion and outer-middle ear filtering are added for DRNL
% To compare the DRNL output directly corresponding to the gammatone
% output, the input to both processors needs to be converted to the stapes output. 

% Obtain the level convention 
% (what dB SPL corresponds to signal level of 1)
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

% Parameters - use full nonlinearity for half of the channels (drnl_mocIpsi = 1)
% and totally suppressed nonlinearity for the other half (drnl_mocIpsi = 0)
par = genParStruct('drnl_lowFreqHz',80,'drnl_highFreqHz',8000,'drnl_nChannels',16, ...
    'drnl_mocIpsi', [zeros(1,8) ones(1,8)]); 

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

zoom  = 2.5;
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

zoom  = 2.5;
bNorm = [];

figure;
waveplot(bm_gt(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);

