clear;
close all
clc


%% Create binaural input signal
% 
% 
% Load a signal
load(['Test_signals',filesep,'TestBinauralCues']);

% Ear signals
earSignals = fliplr(earSignals);
earSignals = earSignals(1:62E3,:);


% Replicate signals at a higher level
earSignals = cat(1,earSignals,5*earSignals)/5;

% Add a sinus @ 0.5 Hz
data = earSignals + repmat(sin(2*pi.*(0:size(earSignals,1)-1).' * 0.5/fsHz),[1 size(earSignals,2)]);

% Time axis
timeSec = (1:size(data,1))/fsHz;


%% Pre-processing settings
% 
% 
% Activate DC removal filter
pp_bRemoveDC  = true;
pp_cutoffHzDC = 20;

% Reference sampling frequency
pp_fsHzRef = 16E3;

% Activate pre-emphasis
pp_bPreEmphasis    = true;
pp_coefPreEmphasis = 0.97;

% Activate RMS normalization
pp_bNormalizeRMS = true;
pp_intTimeSecRMS = 2000E-3;   
    


%% Plot signal
% 
% 

figure;
plot(timeSec(1:3:end),earSignals(1:3:end,:));
title(sprintf('1. Ears signals sampled at %i Hz',fsHz))
xlabel('Time (s)')
ylabel('Amplitude')
xlim([timeSec(1) timeSec(end)])
ylim([-2 2])

figure;
plot(timeSec(1:3:end),data(1:3:end,:));
title('2. Ear signals + sinus at 0.5 Hz')
xlabel('Time (s)')
ylabel('Amplitude')
xlim([timeSec(1) timeSec(end)])
ylim([-2 2])


%% DC removal filter
%
%
if pp_bRemoveDC
    % 4th order @ 20 Hz cutoff
    [bDC,aDC] = butter(4,pp_cutoffHzDC/(fsHz * 0.5),'high');
    
    if isstable(bDC,aDC)
        data = filter(bDC,aDC,data);
    else
        error('IIR filter is not stable, reduce the filter order!')
    end
    
    figure;
    plot(timeSec(1:3:end),data(1:3:end,:));
    title('3. After DC removal')
    xlabel('Time (s)')
    ylabel('Amplitude')
    xlim([timeSec(1) timeSec(end)])
    ylim([-2 2])
end


%% Resampling
%
%
if isempty(pp_fsHzRef) 
    % Do nothing
elseif fsHz > pp_fsHzRef
    % Resample signal
    data = resample(data,pp_fsHzRef,fsHz);
    
    fsHz = pp_fsHzRef;
    
    % Re-create time axis
    timeSec = (1:size(data,1))/pp_fsHzRef;
    
    figure;
    plot(timeSec(1:3:end),data(1:3:end,:));
    title(sprintf('4. After resampling to %i Hz',fsHz))
    xlabel('Time (s)')
    ylabel('Amplitude')
    xlim([timeSec(1) timeSec(end)])
    ylim([-2 2])
else
    error('Upsampling of the input signal is not supported.')
end        


%% Pre-whitening
% 
%
if pp_bPreEmphasis
    % Common choices are between 0.9 and 1
    b = [1 -abs(pp_coefPreEmphasis)];
    a = 1;
    
    % Apply 1st order pre-whitening filter
    data = filter(b, a, data);
    
    figure; 
    plot(timeSec(1:3:end),data(1:3:end,:));
    title('5. After pre-emphasis')
    xlabel('Time (s)')
    ylabel('Amplitude')
    xlim([timeSec(1) timeSec(end)])
    ylim([-2 2])
end


%% Perform AGC
%
%
if pp_bNormalizeRMS
    % Apply AGC to all channels independently
    out1 = agc(data,fsHz,pp_intTimeSecRMS,false);
    
    % Preserve level differences across channels
    out2 = agc(data,fsHz,pp_intTimeSecRMS,true);
    
    figure;
    plot(timeSec(1:3:end),out1(1:3:end,:));
    title('6. After monaural AGC')
    xlabel('Time (s)')
    ylabel('Amplitude')
    xlim([timeSec(1) timeSec(end)])
    ylim([-27 27])

    figure;
    plot(timeSec(1:3:end),out2(1:3:end,:));
    title('7. After binaural AGC')
    xlabel('Time (s)')
    ylabel('Amplitude')
    xlim([timeSec(1) timeSec(end)])
    ylim([-27 27])
end

if 1
   fig2LaTeX(['Pre_Processing_01'],1,18)
   fig2LaTeX(['Pre_Processing_02'],2,18)
   fig2LaTeX(['Pre_Processing_03'],3,18)
   fig2LaTeX(['Pre_Processing_04'],4,18)
   fig2LaTeX(['Pre_Processing_05'],5,18)
   fig2LaTeX(['Pre_Processing_06'],6,18)
   fig2LaTeX(['Pre_Processing_07'],7,18)
end