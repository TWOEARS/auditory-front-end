clear;
close all
clc

% Load a signal
load(['Test_signals',filesep,'TestBinauralCues']);

% Ear signals
earSignals = fliplr(earSignals);
earSignals = earSignals(1:62E3,:);

% Take single channel (R or L)
earSignal = earSignals(:,1);
fprintf('1st half: %.1f dB(SPL), 2nd half: %.1f dB\n', dbspl(earSignal/3), ...
    dbspl(earSignal));

% Replicate signals at a higher level
earSignal = cat(1,earSignal,3*earSignal)/3;
fprintf('Overall: %.1f dB(SPL)\n', dbspl(earSignal));

data = earSignal;     

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
dboffset = dbspl(1);

% Scale signal such that level 1 corresponds to 100 dB SPL
% and apply additional gain (to find a level region where 
% the compressive nonlinearity can be shown effectively)
addGain = -15;              % Change this to adjust final input level
dataScaled = gaindb(data, dboffset-100+addGain);
fprintf('Scaled level: %.1f dB(SPL)\n', dbspl(dataScaled));

% Introduce outer/middle ear filters (imported tools from AMT)
oe_fir = headphonefilter(fsHz);
me_fir = middleearfilter(fsHz,'jepsenmiddleear');

% Convert input to stapes output, through outer-middle ear filters
dataMiddleEar = filter(oe_fir, 1, dataScaled);
dataStapes = filter(me_fir, 1, dataMiddleEar);

% Request DRNL / gammatone
requests_DRNL = {'drnl'};
requests_GT = {'gammatone'};

% Parameters 
par_DRNL = genParStruct('drnl_cfHz', [500 1000 2000 4000 8000], ...
    'drnl_mocIpsi', 1); 
par_GT = genParStruct('fb_cfHz',[500 1000 2000 4000 8000]); 

% Create data objects - here use dataStapes (stapes output, velocity)
dObj = dataObject(dataStapes,fsHz);

% Create a manager
mObj_DRNL = manager(dObj, requests_DRNL, par_DRNL);
mObj_GT = manager(dObj, requests_GT, par_GT);

% Request processing
mObj_DRNL.processSignal();
mObj_GT.processSignal();

tSec = (1:size(data,1))/fsHz;

% % Plot the original input
% figure;
% subplot(3,1,1)
% plot(tSec(1:3:end),data(1:3:end));
% ylabel('Amplitude')
% title('Input signal');
% xlim([tSec(1) tSec(end)]);
% ylim([-1 1])
% 
% % Plot the middle ear "input" (to the stapes)
% subplot(3,1,2)
% plot(tSec(1:3:end),dataMiddleEar(1:3:end));
% ylabel('Amplitude')
% title('Input to the stapes');
% xlim([tSec(1) tSec(end)]);
% ylim([-1 1])
% 
% % Plot the stapes output
% subplot(3,1,3)
% plot(tSec(1:3:end),dataStapes(1:3:end));
% xlabel('Time (s)')
% ylabel('Amplitude')
% title('Stapes output');
% xlim([tSec(1) tSec(end)]);
% % ylim([-1 1])

%% Plot responses
  
zoom_GT  = 3;
zoom_DRNL  = 2;
bNorm = [];

% % Gammatone vs DRNL output for clean source
% figure;
% waveplot(dObj.gammatone{1}.Data(1:3:end,:),tSec(1:3:end),...
%     dObj.gammatone{1}.cfHz,zoom_GT,bNorm);
% title(sprintf('Gammatone filterbank output, clean input (zoom = %.1f)', zoom_GT));
% figure;
% waveplot(dObj.drnl{1}.Data(1:3:end,:),tSec(1:3:end),...
%     dObj.drnl{1}.cfHz,zoom_DRNL,bNorm);
% ylabel('Characteristic frequency (Hz)');
% title(sprintf('DRNL filterbank output, clean input (zoom = %.1f)', zoom_DRNL));

freqIndex = 2;

figure;
plot(tSec, dObj.gammatone{1}.Data(:, freqIndex));
xlim([tSec(1) tSec(end)]);
xlabel('Time (s)');
title(sprintf('Gammatone filterbank output at %d-Hz center frequency', dObj.gammatone{1}.cfHz(freqIndex)));

figure;
plot(tSec, dObj.drnl{1}.Data(:, freqIndex));
xlim([tSec(1) tSec(end)]);
title(sprintf('DRNL filterbank output at %d-Hz BM characteristic frequency', dObj.drnl{1}.cfHz(freqIndex)));
xlabel('Time (s)');





