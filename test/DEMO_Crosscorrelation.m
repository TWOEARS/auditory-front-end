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

% Request 
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



zoom = 5;
bNorm = true;

frameIdx2Plot = 10;

% Get sample indexes in that frame to limit waveforms plot
wSizeSamples = 0.5 * round((cc_wSizeSec * fsHz * 2));
wStepSamples = round((cc_hSizeSec * fsHz));
samplesIdx = (1:wSizeSamples) + ((frameIdx2Plot-1) * wStepSamples);

lagsMS = dObj.crosscorrelation{1}.lags*1E3;
% Plot the waveforms in that frame
h1 = figure; hold on
p1 = genParStruct('color','k','linewidth_s',2);
p2 = genParStruct('color',[0.5 0.5 0.5],'linewidth_s',2);
dObj.time{1}.plot(h1,p1,'rangeSec',[samplesIdx(1) samplesIdx(end)]/fsHz)
dObj.time{2}.plot(h1,p2,'rangeSec',[samplesIdx(1) samplesIdx(end)]/fsHz)
title('Time domain signals')    % Overwrite the title

% Add a legend
hl = legend({'Left ear' 'Right ear'});
hpos = get(hl,'position');
hpos(1) = hpos(1) * 0.95;
hpos(2) = hpos(2) * 0.975;
set(hl,'position',hpos);

% Axes limits
xlim([samplesIdx(1) samplesIdx(end)]/fsHz)
ylim([-0.35 0.35])

% hp = plot(samplesIdx/fsHz,[dObj.time{1}.Data(samplesIdx) dObj.time{2}.Data(samplesIdx)]);
% set(hp(1),'color',[0 0 0],'linewidth',2);
% set(hp(2),'color',[0.5 0.5 0.5],'linewidth',2);
% hl = legend({'Left ear' 'Right ear'});
% hpos = get(hl,'position');
% hpos(1) = hpos(1) * 0.95;
% hpos(2) = hpos(2) * 0.975;
% set(hl,'position',hpos);
% 
% xlim([samplesIdx(1) samplesIdx(end)]/fsHz)
% ylim([-0.35 0.35])
% xlabel('Time (s)')
% ylabel('Amplitude')
% title('Time domain signals')

% Plot the cross-correlation in that frame
p3 = genParStruct('corPlotZoom',5)
dObj.crosscorrelation{1}.plot([],p3,frameIdx2Plot)


%% Show a CCF movie
% 
% 
if 1
    h3 = figure;
    % Pause in seconds between two consecutive plots 
    pauseSec = 0.0125;
    dObj.crosscorrelation{1}.plot(h3,p3,1);
    
    % Loop over the number of frames
    for ii = 2 : size(dObj.crosscorrelation{1}.Data(:),1)
        h31=get(h3,'children');
        cla(h31(1)); cla(h31(2));
        
        dObj.crosscorrelation{1}.plot(h3,p3,ii);
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

