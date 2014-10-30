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
requests = {'offset_strength'};

rm_wSizeSec = 20E-3;
rm_hSizeSec = 10E-3;
rm_decaySec = 8E-3;

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',64,'ihc_method','dau','rm_decaySec',rm_decaySec,'rm_wSizeSec',rm_wSizeSec,'rm_hSizeSec',rm_hSizeSec); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Plot offset strength in dB
% 
% 
dObj.ratemap_power{1}.plot;
dObj.offset_strength{1}.plot;


%% Compute binary offset map
% 
%
% Onset strength
onsetStrength = [dObj.offset_strength{1}.Data(:)];
% Step size in seconds
stepSizeSec = 1/dObj.offset_strength{1}.FsHz;

% Detect offsets
bOffsets = detectOnsetsOffsets(onsetStrength,stepSizeSec);


%% Plot binary onset map
% 
% 
% Determine size of onset map
[nFrames,nChannels] = size(onsetStrength);

% Time axis
timeSec = rm_wSizeSec + ((0:nFrames-1) * stepSizeSec);

figure;
imagesc(timeSec,1:nChannels,10*log10([dObj.ratemap_power{1}.Data(:)]'),[-100 -25]);
axis xy
hold on;

% Loop over number of channels
for ii = 1 : nChannels
    data = repmat(timeSec(bOffsets(:,ii) ~= 0)-0.5 * stepSizeSec,[2 1]);
    if ~isempty(data)
        plot(data,ii-0.5:ii+0.5,'Color','w','LineWidth',3);
    end
end



