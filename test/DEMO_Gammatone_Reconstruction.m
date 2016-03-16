clear;
close all
clc


%% LOAD SIGNAL
% 
% 
% Sampling frequency in Hertz
fsHz = 44.1E3;

% Create centered impulse 
dObj = dataObject([zeros(1E3,1); 1; zeros(1E3,1)],fsHz);


%% PLACE REQUEST AND CONTROL PARAMETERS
% 
% 
% Request gammatone processor
requests = {'filterbank'};

% Parameters of auditory filterbank 
fb_type       = 'gammatone';
fb_nChannels  = [];  
fb_lowFreqHz  = 0;
fb_highFreqHz = fsHz/2;
fb_bAlign_1   = false;   % without phase-alignment
fb_bAlign_2   = true;    % with phase-alignment

% Summary of parameters 
par1 = genParStruct('fb_type',fb_type,'fb_lowFreqHz',fb_lowFreqHz,...
                    'fb_highFreqHz',fb_highFreqHz,...
                    'fb_nChannels',fb_nChannels,'fb_bAlign',fb_bAlign_1);
par2 = genParStruct('fb_type',fb_type,'fb_lowFreqHz',fb_lowFreqHz,...
                    'fb_highFreqHz',fb_highFreqHz,...
                    'fb_nChannels',fb_nChannels,'fb_bAlign',fb_bAlign_2);                
                   

%% PERFORM PROCESSING
% 
% 
% Create a manager
mObj1 = manager(dObj,requests,par1);
mObj2 = manager(dObj,requests,par2);

% Request processing
mObj1.processSignal();
mObj2.processSignal();


%% PERFORM TIME-ALIGNMENT
% 
% 
% Filter bandwidth in Hertz
bwHz  = 1.018 * (24.7 + 0.108 * dObj.filterbank{1}.cfHz);
delay = 3./(2*pi*bwHz);

% This is when the function peaks
delayInSamples = round(delay * dObj.filterbank{1}.FsHz);

% Compensate for integer delays
aligned1 = dObj.filterbank{1}.Data(:).';
aligned2 = dObj.filterbank{2}.Data(:).';

% Loop over number of subbands
for ii = 1 : numel(delayInSamples)
    aligned1(ii,:) = circshift(aligned1(ii,:),[1 -delayInSamples(ii)]);
    aligned2(ii,:) = circshift(aligned2(ii,:),[1 -delayInSamples(ii)]);
end


%% PLOT RESULTS
% 
% 
% Plot-related parameters
wavPlotZoom = 5; % Zoom factor
wavPlotDS   = 3; % Down-sampling factor

% Summarize plot parameters
p = genParStruct('wavPlotZoom',wavPlotZoom,'wavPlotDS',wavPlotDS);

% Plot filterbank output (no delay compensation)
dObj.filterbank{1}.plot([],p);
dObj.filterbank{2}.plot([],p);

% Time vector
timeSec = (0:size(aligned1,2)-1)/fsHz;

% Plot delay-compensated filterbank output
figure; 
waveplot(aligned1',timeSec,dObj.filterbank{1}.cfHz,wavPlotZoom,wavPlotDS);
title('Delay-compensated output (without phase compensation)')

figure; 
waveplot(aligned2',timeSec,dObj.filterbank{1}.cfHz,wavPlotZoom,wavPlotDS);
title('Delay-compensated output (with phase compensation)')

figure;
plot(timeSec,[sum(aligned1,1); sum(aligned2,1)]);
title('Reconstructed impulse');
grid on;
legend({'without phase compensation' 'with phase compensation'})
