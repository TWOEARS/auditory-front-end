clear;
% close all
clc


% preset = 'anechoic';
preset = 'reverberant';


% Load a signal
switch lower(preset)
    case 'anechoic'
        load('DEMO_Speech_Anechoic');
    case 'reverberant'
        load('DEMO_Speech_Room_D');
    otherwise
        error('Preset is not supported')
end

% Take right ear signal
data = earSignals(1:22494,:); 

% Request ratemap    
requests = {'ic' 'itd'};

cc_wSizeSec = 0.02;
cc_hSizeSec = 0.01;

% Parameters
par = genParStruct('fb_lowFreqHz',80,'fb_highFreqHz',8000,'fb_nChannels',32,'ihc_method','dau','cc_wSizeSec',cc_wSizeSec,'cc_hSizeSec',cc_hSizeSec); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();

sigL = [dObj.time{1}.Data(:)];
sigR = [dObj.time{2}.Data(:)];

timeSec = (1:numel(sigL))/fsHz;

ic = [dObj.ic{1}.Data(:)];
itd = [dObj.itd{1}.Data(:)];
freqHz = dObj.ic{1}.cfHz;

[nFrames,nChannels] = size(ic);

wSizeSamples = 0.5 * round((cc_wSizeSec * fsHz * 2));
wStepSamples = round((cc_hSizeSec * fsHz));

tSec = (wSizeSamples + (0:nFrames-1)*wStepSamples)/fsHz;

figure;
hp = plot(timeSec(1:3:end),[sigR(1:3:end) sigL(1:3:end)]');
set(hp(1),'color',[0 0 0],'linewidth',2);
set(hp(2),'color',[0.5 0.5 0.5],'linewidth',2);
hl = legend({'Right ear' 'Left ear'});
hpos = get(hl,'position');
hpos(1) = hpos(1) * 0.95;
hpos(2) = hpos(2) * 0.975;
set(hl,'position',hpos);

xlabel('Time (sec)')
ylabel('Amplitude')
grid on
ylim([-1.25 1.25])
xlim([timeSec(1) timeSec(end)])
title(['Time domain signals',' (',preset,')'])

figure;
imagesc(tSec,1:nChannels,ic')
axis xy;
colorbar;
title(['IC',' (',preset,')'])
xlabel('Time (s)')
ylabel('Center frequency (Hz)')

set(gca,'CLim',[0 1])

nYLabels = 8;
 
% Find the spacing for the y-axis which evenly divides the y-axis
set(gca,'ytick',linspace(1,nChannels,nYLabels));
set(gca,'yticklabel',round(interp1(1:nChannels,freqHz,linspace(1,nChannels,nYLabels))));


% bReliable = ic(:) > 0.985;
% 
% theGrid = linspace(-1,1,15);
% 
% input1 = 1E3*itd(:);
% input2 = input1(bReliable);
% 
% data1 = hist(input1,theGrid)/numel(input1);
% data2 = hist(input2,theGrid)/numel(input2);
% 
% figure;
% bar(theGrid,data1);
% figure;
% bar(theGrid,data2);
% 
% figure;
% imagesc(tSec,1:nChannels,1E3*itd')
% axis xy;
% colorbar;
% title('ITD')
% xlabel('Time (s)')
% ylabel('Center frequency (Hz)')
% 
% nYLabels = 8;
%  
% % Find the spacing for the y-axis which evenly divides the y-axis
% set(gca,'ytick',linspace(1,nChannels,nYLabels));
% set(gca,'yticklabel',round(interp1(1:nChannels,freqHz,linspace(1,nChannels,nYLabels))));




% fig2LaTeX(['IC_01'],1,16);fig2LaTeX(['IC_02'],2,16)

