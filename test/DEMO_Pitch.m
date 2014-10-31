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

% Request ratemap    
requests = {'autocorrelation'};

ac_wSizeSec   = 0.032;
ac_hSizeSec   = 0.016;
ac_clipAlpha  = 0.0;
ac_K          = 2;
pitchRangeHz  = [80 400];
confThresPerc = 0.7;
orderMedFilt  = 3;

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',16,'ihc_method','dau','ac_wSizeSec',ac_wSizeSec,'ac_hSizeSec',ac_hSizeSec,'ac_clipAlpha',ac_clipAlpha,'ac_K',ac_K); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();

% Get ACF and lag vector
acf  = [dObj.autocorrelation{1}.Data(:)];
lags = dObj.autocorrelation{1}.lags;


%% Estimate Pitch
% 
% 
% Estimate most dominant pitch within
[pitchHz,confidence,thres,pitchRawHz] = estPitch_SACF(acf,lags,pitchRangeHz,confThresPerc,orderMedFilt);

nFrames = numel(pitchHz);

wSizeSamples = 0.5 * round((ac_wSizeSec * fsHz * 2));
wStepSamples = round((ac_hSizeSec * fsHz));

timeSec = (wSizeSamples + (0:nFrames-1)*wStepSamples)/fsHz;
timeSecSig = (1:numel(data))/fsHz;

% Restrict lags to plausible pitch range
rangeLags = 1./pitchRangeHz;

% Find corresponding lags
% bValidLags = lags >= min(rangeLags) & lags <= min(max(rangeLags),size(acf,3));

% freqAxisHz = 1./lags(bValidLags);

freqAxisHz = 1./lags;

sacf = squeeze(mean(acf,2));


figure;
plot(timeSecSig,data);
xlim([timeSecSig(1) timeSec(end)])
ylim([-1 1])
xlabel('Time (s)');
ylabel('Amplitude');
title('Time domain signal')

figure;
imagesc(timeSec,lags,sacf');
colorbar;
hold on;
ylim([0 0.02])
for ii = 1 : nFrames
    plot(timeSec(ii),1/pitchRawHz(ii),'kx','linewidth',2,'markersize',8)
end
plot([timeSec(1) timeSec(end)],[min(rangeLags) min(rangeLags)],'w--','linewidth',2)
plot([timeSec(1) timeSec(end)],[max(rangeLags) max(rangeLags)],'w--','linewidth',2)
xlim([timeSec(1) timeSec(end)])
axis xy
title('SACF')
xlabel('Time (s)')
ylabel('Lag period (s)')

figure;
plot(timeSec,confidence,'-k','linewidth',1.25);
hold on;
[maxVal,maxIdx] = max(confidence);
plot(timeSec(maxIdx),maxVal,'rx','linewidth',2,'markersize',12);
hp = plot([timeSec(1) timeSec(end)],[thres thres],'--k');
hl = legend({'SACF magnitude' 'global maximum' 'confidence threshold'},'location','southeast');
hlpos = get(hl,'position');
hlpos(1) = hlpos(1) * 0.85;
hlpos(2) = hlpos(2) * 1.35;
set(hl,'position',hlpos);
grid on;
set(hp,'linewidth',2)
xlabel('Time (s)')
ylabel('Magnitude')
xlim([timeSec(1) timeSec(end)])
ylim([0 1])
title('Confidence measure')

figure;
h = plot(timeSec,pitchHz,'o');
grid on;
set(h,'markerfacecolor','k','color','k')
xlabel('Time (s)')
ylabel('Frequency (Hz)')
xlim([timeSec(1) timeSec(end)])
ylim(pitchRangeHz)
title('Estimated pitch contour')


if 0
   fig2LaTeX('Pitch_01',1,16);
   fig2LaTeX('Pitch_02',2,16);
   fig2LaTeX('Pitch_03',3,16);
   fig2LaTeX('Pitch_04',4,16);
end
