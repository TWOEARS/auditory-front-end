clear;
close all
clc

%% INITIALIZATION
%
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
requests = {'pitch'};

ac_wSizeSec   = 0.032;
ac_hSizeSec   = 0.016;
ac_clipAlpha  = 0.0;
ac_K          = 2;
pitchRangeHz  = [80 400];
confThresPerc = 0.7;
orderMedFilt  = 3;

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',16,'ihc_method','dau','ac_wSizeSec',ac_wSizeSec,'ac_hSizeSec',ac_hSizeSec,'ac_clipAlpha',ac_clipAlpha,'ac_K',ac_K); 

%% AFE PROCESSING
% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);


% Request processing
mObj.processSignal();


%% PLOTTING RESULTS
% Plot time-domain signal
dObj.time{1}.plot;   

% Autocorrelation with raw pitch overlay (in the lag domain)
h2 = figure;
dObj.autocorrelation{1}.plot(h2);  
ylim([0 0.02])
hold on
dObj.pitch{1}.plot(h2,'rawPitch','pitchRange',mObj.Processors{5}.pitchRangeHz,...
                                 'lagDomain',1);

% Confidence plot with threshold
h3 = figure;
dObj.pitch{1}.plot(h3,'confidence','confThres',mObj.Processors{5}.confThresPerc);

% Final pitch estimation
h4 = figure;
dObj.pitch{1}.plot(h4,'pitch','pitchRange',mObj.Processors{5}.pitchRangeHz)

% Save to latex
if 0
   fig2LaTeX('Pitch_01',1,16);
   fig2LaTeX('Pitch_02',2,16);
   fig2LaTeX('Pitch_03',3,16);
   fig2LaTeX('Pitch_04',4,16);
end
