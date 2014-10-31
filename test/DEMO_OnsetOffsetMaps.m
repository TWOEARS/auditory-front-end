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
requests = {'onset_strength' 'offset_strength'};

% Minimum ratemap level in dB below which onsets or offsets are not considered
minRatemapLeveldB = -80;

% Ratemap settings
rm_wSizeSec = 20E-3;
rm_hSizeSec = 10E-3;
rm_decaySec = 8E-3;
nChannels   = 64;

% Onset parameters
minOnsetStrengthdB  = 3;
minOnsetSpread      = 5;
fuseOnsetsWithinSec = 30E-3;

% Offset parameters
minOffsetStrengthdB  = 3;
minOffsetSpread      = 5;
fuseOffsetsWithinSec = 30E-3;


% % Onset parameters
% minOnsetStrengthdB  = 0;
% minOnsetSpread      = 1;
% fuseOnsetsWithinSec = 0;
% 
% % Offset parameters
% minOffsetStrengthdB  = 0;
% minOffsetSpread      = 1;
% fuseOffsetsWithinSec = 0;


% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',nChannels,'ihc_method','dau','rm_decaySec',rm_decaySec,'rm_wSizeSec',rm_wSizeSec,'rm_hSizeSec',rm_hSizeSec); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Compute binary onset and offset maps
% 
%
% Onset and offset strength
onsetStrength  = [dObj.onset_strength{1}.Data(:)];
offsetStrength = [dObj.offset_strength{1}.Data(:)];

% Step size in seconds
stepSizeSec = 1/dObj.onset_strength{1}.FsHz;

% Get ratemap in dB
ratemap_dB = 10*log10([dObj.ratemap_power{1}.Data(:)]);

% Delete activity which is below "minLeveldB"
bSet2zero = ratemap_dB  < minRatemapLeveldB;

onsetStrength(bSet2zero)  = 0;
offsetStrength(bSet2zero) = 0;

% Detect onsets and offsets
bOnsets  = detectOnsetsOffsets(onsetStrength,stepSizeSec,minOnsetStrengthdB,minOnsetSpread,fuseOnsetsWithinSec);
bOffsets = detectOnsetsOffsets(offsetStrength,stepSizeSec,minOffsetStrengthdB,minOffsetSpread,fuseOffsetsWithinSec);


%% Plot binary onset map
% 
% 
% Determine size of onset map
[nFrames,nChannels] = size(onsetStrength);

% Time axis
timeSec = rm_wSizeSec + ((0:nFrames-1) * stepSizeSec);

figure;
imagesc(timeSec,1:nChannels,ratemap_dB',[-100 -25]);
xlabel('Time (s)')
ylabel('Center frequency (Hz)')
axis xy
hold on;

% Loop over number of channels
for ii = 1 : nChannels
    data = repmat(timeSec(bOnsets(:,ii) ~= 0)-0.5 * stepSizeSec,[2 1]);
    if ~isempty(data)
        plot(data,ii-0.5:ii+0.5,'Color','k','LineWidth',2);
    end
end

% Loop over number of channels
for ii = 1 : nChannels
    data = repmat(timeSec(bOffsets(:,ii) ~= 0)-0.5 * stepSizeSec,[2 1]);
    if ~isempty(data)
        plot(data,ii-0.5:ii+0.5,'Color','w','LineWidth',2);
    end
end

nYLabels = 8;
 
% Find the spacing for the y-axis which evenly divides the y-axis
set(gca,'ytick',linspace(1,nChannels,nYLabels));
set(gca,'yticklabel',round(interp1(1:nChannels,dObj.onset_strength{1}.cfHz,linspace(1,nChannels,nYLabels))));


