clear;
close all
clc


% Load a signal
load('TestBinauralCues');

% Take right ear signal
data = earSignals(1:62E3,:); 

% % New sampling frequency
% fsHzRef = 16E3;
% 
% % Resample
% data = resample(data,fsHzRef,fsHz);
% 
% % Copy fs
% fsHz = fsHzRef;

% Request ratemap    
requests = {'crosscorrelation'};

cc_wSizeSec = 0.02;
cc_hSizeSec = 0.01;

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',32,'ihc_method','dau','cc_wSizeSec',cc_wSizeSec,'cc_hSizeSec',cc_hSizeSec); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();

ihcL = [dObj.innerhaircell{1}.Data(:)];
ihcR = [dObj.innerhaircell{2}.Data(:)];

ccf = [dObj.crosscorrelation{1}.Data(:)];


%% Plot the CCF

% Pause in seconds between two consecutive plots 
pauseSec = 0.125;

zoom = 5;
bNorm = true;

frameIdx2Plot = 10;

wSizeSamples = 0.5 * round((cc_wSizeSec * fsHz * 2));
wStepSamples = round((cc_hSizeSec * fsHz));

samplesIdx = (1:wSizeSamples) + ((frameIdx2Plot-1) * wStepSamples);

lagsMS = dObj.crosscorrelation{1}.lags*1E3;

figure;
hp = plot(samplesIdx/fsHz,[dObj.time{1}.Data(samplesIdx) dObj.time{2}.Data(samplesIdx)]);
set(hp(1),'color',[0 0 0],'linewidth',2);
set(hp(2),'color',[0.5 0.5 0.5],'linewidth',2);
hl = legend({'Left ear' 'Right ear'});
hpos = get(hl,'position');
hpos(1) = hpos(1) * 0.95;
hpos(2) = hpos(2) * 0.975;
set(hl,'position',hpos);

xlim([samplesIdx(1) samplesIdx(end)]/fsHz)
ylim([-0.35 0.35])
xlabel('Time (s)')
ylabel('Amplitude')
title('Time domain signals')

figure;
ax(1) = subplot(4,1,[1:3]);
waveplot(permute(ccf(frameIdx2Plot,:,:),[3 1 2]),lagsMS,dObj.crosscorrelation{1}.cfHz,zoom,bNorm)
xlabel('')
hy = ylabel('Center frequency (Hz)');
hypos = get(hy,'position');
hypos(1) = -1.35;
set(hy,'position',hypos);

ht = title('CCF');
htpos = get(ht,'position');
htpos(2) = htpos(2) * 0.985;
set(ht,'position',htpos);


ax(2) = subplot(4,1,4);
plot(lagsMS,mean(permute(ccf(frameIdx2Plot,:,:),[3 1 2]),3),'k','linewidth',1.25)
grid on
xlim([lagsMS(1) lagsMS(end)])
ylim([0.5 1])
xlabel('Lag period (ms)')
ylabel('SCCF')


%% Show a ACF movie
% 
% 
if 0
    figure;
    
    % Loop over the number of frames
    for ii = 1 : size(ccf,1)
        cla;
        waveplot(permute(ccf(ii,:,:),[3 1 2]),dObj.crosscorrelation{1}.lags,dObj.crosscorrelation{1}.cfHz,zoom,bNorm)
        pause(pauseSec);
        title(['Frame number ',num2str(ii)])
    end
end


% %% Plot Gammatone response
% % 
% % 
% % Basilar membrane output
% bm   = [dObj.gammatone{1}.Data(:,:)];
% % Envelope
% env  = [dObj.innerhaircell{1}.Data(:,:)];
% fHz  = dObj.gammatone{1}.cfHz;
% tSec = (1:size(bm,1))/fsHz;
% 
% zoom  = [];
% bNorm = [];
% 
% 
% figure;
% waveplot(bm(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);
% 
% figure;
% waveplot(env(1:3:end,:),tSec(1:3:end),fHz,zoom,bNorm);

