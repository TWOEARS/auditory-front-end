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

data = earSignal(1:62E3);     
dataNoisy = earSignalNoisy(1:62E3);

% New sampling frequency
fsHzRef = 16E3;

% Resample
data = resample(data,fsHzRef,fsHz);
dataNoisy = resample(dataNoisy, fsHzRef, fsHz);

% Copy fs
fsHz = fsHzRef;

% The level conversion and outer-middle ear filtering are added for DRNL
% To compare the DRNL output directly corresponding to the gammatone
% output, the input to both processors needs to be converted to the stapes output. 

% Obtain the level convention 
% (what dB SPL corresponds to signal level of 1)
dboffset = dbspl(1);

% Scale signal such that level 1 corresponds to 100 dB SPL
dataScaled = gaindb(data, dboffset-100);
dataNoisyScaled = gaindb(dataNoisy, dboffset-100);

% Introduce outer/middle ear filters (imported tools from AMT)
oe_fir = headphonefilter(fsHz);
me_fir = middleearfilter(fsHz,'jepsenmiddleear');

% Convert input to stapes output, through outer-middle ear filters
dataMiddleEar = filter(oe_fir, 1, dataScaled);
dataStapes = filter(me_fir, 1, dataMiddleEar);
dataNoisyMiddleEar = filter(oe_fir, 1, dataNoisyScaled);
dataNoisyStapes = filter(me_fir, 1, dataNoisyMiddleEar);

% Request DRNL / gammatone    
requests_DRNL = {'drnl'};
requests_GT = {'gammatone'};

% Parameters - use full nonlinearity for half of the channels (drnl_mocIpsi = 1)
% and totally suppressed nonlinearity for the other half (drnl_mocIpsi = 0)
par_DRNL = genParStruct('drnl_lowFreqHz',80,'drnl_highFreqHz',8000,'drnl_nChannels',16, ...
    'drnl_mocIpsi', 1); 
par_GT = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',16); 

% Create data objects - here use dataStapes (stapes output, velocity)
dObj = dataObject(dataStapes,fsHz);
dObjNoisySource = dataObject(dataNoisyStapes, fsHz);

% Create a manager
mObj_DRNL = manager(dObj, requests_DRNL, par_DRNL);
mObjNoisySource_DRNL = manager(dObjNoisySource, requests_DRNL, par_DRNL);
mObj_GT = manager(dObj, requests_GT, par_GT);
mObjNoisySource_GT = manager(dObjNoisySource, requests_GT, par_GT);

% Request processing
mObj_DRNL.processSignal();
mObjNoisySource_DRNL.processSignal();
mObj_GT.processSignal();
mObjNoisySource_GT.processSignal();

tSec = (1:size(data,1))/fsHz;

% Plot the original input (noisy speech)
figure;
subplot(3,1,1)
plot(tSec(1:3:end),dataNoisy(1:3:end));
ylabel('Amplitude')
title('Input signal');
xlim([tSec(1) tSec(end)]);
ylim([-1 1])

% Plot the middle ear "input" (to the stapes)
subplot(3,1,2)
plot(tSec(1:3:end),dataNoisyMiddleEar(1:3:end));
ylabel('Amplitude')
title('Input to the stapes');
xlim([tSec(1) tSec(end)]);
ylim([-1 1])

% Plot the stapes output
subplot(3,1,3)
plot(tSec(1:3:end),dataNoisyStapes(1:3:end));
xlabel('Time (s)')
ylabel('Amplitude')
title('Stapes output');
xlim([tSec(1) tSec(end)]);
% ylim([-1 1])

%% Plot responses
  
zoom_GT  = 4;
zoom_DRNL  = 2.1;
bNorm = [];

% Gammatone vs DRNL output for clean source
figure;
waveplot(dObj.gammatone{1}.Data(1:3:end,:),tSec(1:3:end),...
    dObj.gammatone{1}.cfHz,zoom_GT,bNorm);
title(sprintf('Gammatone filterbank output, clean input (zoom = %.1f)', zoom_GT));
figure;
waveplot(dObj.drnl{1}.Data(1:3:end,:),tSec(1:3:end),...
    dObj.drnl{1}.cfHz,zoom_DRNL,bNorm);
ylabel('Characteristic frequency (Hz)');
title(sprintf('DRNL filterbank output, clean input (zoom = %.1f)', zoom_DRNL));

figure;
waveplot(dObjNoisySource.gammatone{1}.Data(1:3:end,:),tSec(1:3:end),...
    dObjNoisySource.gammatone{1}.cfHz,zoom_GT,bNorm);
title(sprintf('Gammatone filterbank output, noisy input (zoom = %.1f)', zoom_GT));
figure;
waveplot(dObjNoisySource.drnl{1}.Data(1:3:end,:),tSec(1:3:end),...
    dObjNoisySource.drnl{1}.cfHz,zoom_DRNL,bNorm);
ylabel('Characteristic frequency (Hz)');
title(sprintf('DRNL filterbank output, noisy input (zoom = %.1f)', zoom_DRNL));

