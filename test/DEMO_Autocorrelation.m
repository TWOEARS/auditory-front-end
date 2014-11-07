clear;
close all
clc


% Load a signal
load('TestBinauralCues');

% Take right ear signal
data = earSignals(1:62E3,2); 
% data = earSignals(1:15E3,2);     

% New sampling frequency
fsHzRef = 16E3;

% Resample
data = resample(data,fsHzRef,fsHz);

% Copy fs
fsHz = fsHzRef;

% Request ratemap    
requests = {'autocorrelation'};

ac_wSizeSec  = 0.02;
ac_hSizeSec  = 0.01;
ac_clipAlpha = 0.0;
ac_K         = 2;


% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',16,'ihc_method','dau','ac_wSizeSec',ac_wSizeSec,'ac_hSizeSec',ac_hSizeSec,'ac_clipAlpha',ac_clipAlpha,'ac_K',ac_K); 

% Create a data object
dObj = dataObject(data,fsHz);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Plot the ACF

frameIdx2Plot = 10;     % Plot the ACF in a single frame

% Get the corresponding sample range for plotting the ihc in that range
wSizeSamples = 0.5 * round((ac_wSizeSec * fsHz * 2));
wStepSamples = round((ac_hSizeSec * fsHz));
samplesIdx = (1:wSizeSamples) + ((frameIdx2Plot-1) * wStepSamples);

% Plot the IHC output in that frame
par = genParStruct('wavPlotZoom',3,'wavPlotDS',1);
dObj.innerhaircell{1}.plot([],par,'rangeSec',[samplesIdx(1) samplesIdx(end)]/fsHz)

% Plot the autocorrelation in that frame
dObj.autocorrelation{1}.plot([],[],frameIdx2Plot)




%% Show a ACF movie
% 
% y-axis is slightly moving in the movie, might consider fixing it
if 0
    figure;
    pauseSec = 0.0125;  % Pause between two consecutive plots
    % Loop over the number of frames
    for ii = 1 : size(acf,1)
        cla;
        waveplot(permute(acf(ii,:,:),[3 1 2]),dObj.autocorrelation{1}.lags,dObj.autocorrelation{1}.cfHz)
        pause(pauseSec);
        title(['Frame number ',num2str(ii)])
    end
end


