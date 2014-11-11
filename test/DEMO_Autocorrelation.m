clear;
close all
clc


%% LOAD SIGNAL
% 
% 
% Load a signal
load('AFE_earSignals_16kHz');

% Create a data object based on parts of the right ear signal
dObj = dataObject(earSignals(1:20E3,2),fsHz);


%% PLACE REQUEST AND CONTROL PARAMETERS
% 
% 
% Request auto-corrleation function (ACF)
requests = {'autocorrelation'};

ac_wSizeSec  = 0.032;
ac_hSizeSec  = 0.016;
ac_clipAlpha = 0.0;
ac_K         = 2;
ac_wname     = 'hann';

% Parameters
par = genParStruct('gt_lowFreqHz',80,'gt_highFreqHz',8000,'gt_nChannels',16,'ihc_method','dau','ac_wSizeSec',ac_wSizeSec,'ac_hSizeSec',ac_hSizeSec,'ac_clipAlpha',ac_clipAlpha,'ac_K',ac_K,'ac_wname',ac_wname); 

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
dObj.innerhaircell{1}.plot([],par,'rangeSec',[samplesIdx(1) samplesIdx(end)]/fsHz);

% Plot the autocorrelation in that frame
dObj.autocorrelation{1}.plot([],[],frameIdx2Plot);




%% Show a ACF movie
% 
if 0
    h3 = figure;
    pauseSec = 0.0125;  % Pause between two consecutive plots
    dObj.autocorrelation{1}.plot(h3,par,1);
    
    % Loop over the number of frames
    for ii = 1 : size(dObj.autocorrelation{1}.Data(:),1)
        h31=get(h3,'children');
        cla(h31(1)); cla(h31(2));
        
        dObj.autocorrelation{1}.plot(h3,par,ii,'noTitle',1);
        pause(pauseSec);
        title(h31(2),['Frame number ',num2str(ii)])
    end
end


