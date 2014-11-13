clear;
close all
clc


%% Create binaural input signal
% 
% 
% Load a signal
load AFE_earSignals_44p1kHz

% Ear signals
earSignals = fliplr(earSignals);
earSignals = earSignals(1:62E3,:);

% Replicate signals at a higher level
earSignals = cat(1,earSignals,5*earSignals)/5;

% Add a sinus @ 0.5 Hz
data = earSignals + repmat(0.5*sin(2*pi.*(0:size(earSignals,1)-1).' * 0.5/fsHz),[1 size(earSignals,2)]);

% Time axis
timeSec = (1:size(data,1))/fsHz;


%% Pre-processing settings
% 
% 
% Activate DC removal filter
bRemoveDC  = true;
cutoffHzDC = 20;

% Activate pre-emphasis
bPreEmphasis    = true;
coefPreEmphasis = 0.97;

% Activate RMS normalization
bNormalizeRMS = true;
intTimeSecRMS = 500E-3;   
    
% Apply level scaling to reference
pp_bLevelScaling = true;
pp_refSPLdB = 100;

% Apply middle ear filtering
pp_bMiddleEarFiltering = true;
pp_middleEarModel = 'jepsen';

% Plot properties
p_plot = genParStruct('fsize_label',10,'fsize_axes',10,'fsize_title',10);


%% Plot signal
% 
% 

% Instantiate signals
dataObj_ear = dataObject(earSignals,fsHz); % Original signal (for plotting purpose)
dataObj = dataObject(data,fsHz);       % Actual input signal

% Plot the original ear signal
dataObj_ear.plot([],p_plot,'bGray',1,'decimateRatio',3,'bSignal',1);
legend off, ylim([-1.5 1.5])
title(sprintf('1. Ears signals sampled at %i Hz',fsHz))

% Plot the input to the pre-processor
dataObj.plot([],p_plot,'bGray',1,'decimateRatio',3,'bSignal',1);
legend off, ylim([-1.5 1.5])
title('2. Ear signals + sinus at 0.5 Hz')


%% DC removal filter
%
%

% Apply DC removal only
p = genParStruct('pp_bRemoveDC',bRemoveDC,'pp_cutoffHzDC',cutoffHzDC);

mObj_DC = manager(dataObj,'time',p);
mObj_DC.processSignal;

% Plot the result
dataObj.plot([],p_plot,'bGray',1,'decimateRatio',3);
legend off, ylim([-1.5 1.5])
title('3. After DC removal')


%% Pre-whitening
% 
%

% New data object
dataObj = dataObject(data,fsHz);

% Apply DC removal and pre-whitening
p = genParStruct('pp_bRemoveDC',bRemoveDC,'pp_cutoffHzDC',cutoffHzDC,...
                 'pp_bPreEmphasis',bPreEmphasis,'pp_coefPreEmphasis',coefPreEmphasis);
             
mObj_PW = manager(dataObj,'time',p);
mObj_PW.processSignal;

% Plot the result
dataObj.plot([],p_plot,'bGray',1,'decimateRatio',3);
legend off, ylim([-1.5 1.5])
title('4. After pre-emphasis')


%% Perform AGC
%
%

% New data object
dataObj = dataObject(data,fsHz);
dataObj2 = dataObject(data,fsHz);

% Apply DC removal, pre-whitening, and AGC
pmono = genParStruct('pp_bRemoveDC',bRemoveDC,'pp_cutoffHzDC',cutoffHzDC,...
                 'pp_bPreEmphasis',bPreEmphasis,'pp_coefPreEmphasis',coefPreEmphasis,...
                 'pp_bNormalizeRMS',bNormalizeRMS,'pp_intTimeSecRMS',intTimeSecRMS,...
                 'pp_bBinauralRMS',0);
             
pbin = genParStruct('pp_bRemoveDC',bRemoveDC,'pp_cutoffHzDC',cutoffHzDC,...
                 'pp_bPreEmphasis',bPreEmphasis,'pp_coefPreEmphasis',coefPreEmphasis,...
                 'pp_bNormalizeRMS',bNormalizeRMS,'pp_intTimeSecRMS',intTimeSecRMS,...
                 'pp_bBinauralRMS',1);
             
mObj_monoAGC = manager(dataObj,'time',pmono);
mObj_binAGC = manager(dataObj2,'time',pbin);

mObj_monoAGC.processSignal;
mObj_binAGC.processSignal;

% Plot the result
dataObj.plot([],p_plot,'bGray',1,'decimateRatio',3);
legend off, ylim([-18 18])
title('5. After monaural AGC')

dataObj2.plot([],p_plot,'bGray',1,'decimateRatio',3);
legend off, ylim([-18 18])
title('6. After binaural AGC')



%% Level scaling to reference


if pp_bLevelScaling
    % Get the pre-processed data from earlier stage
    data = [dataObj2.time{1}.Data(:) dataObj2.time{2}.Data(:)];

    % Obtain what the current calibration reference is 
    current_dboffset = dbspl(1);
    % Adjust level corresponding to the given reference
    data = gaindb(data, current_dboffset-pp_refSPLdB);
    
    % Simple scaling so no need for plotting
    
end


%% Middle ear filtering

data = earSignals;
if pp_bMiddleEarFiltering
    % Obtain the filter coefficients corresponding to the given model
    if strcmp(pp_middleEarModel, 'jepsen')
        pp_middleEarModel = 'jepsenmiddleear'; 
    end
    a = 1;
    b = middleearfilter(fsHz, pp_middleEarModel);
    % Apply filtering
    data = filter(b, a, data);
 
    figure;
    h = plot(timeSec(1:3:end),data(1:3:end,:));
    set(h(1),'color',[0 0 0]);
    set(h(2),'color',[0.5 0.5 0.5]);
    title('7. After middle ear filtering (input from panel 1)')
    xlabel('Time (s)')
    ylabel('Amplitude')
    xlim([timeSec(1) timeSec(end)])
%     ylim([-18 18])
    
end





%% Save figures
if 0
   mode = 20;
   fig2LaTeX(['Pre_Processing_01'],1,mode)
   fig2LaTeX(['Pre_Processing_02'],2,mode)
   fig2LaTeX(['Pre_Processing_03'],3,mode)
   fig2LaTeX(['Pre_Processing_04'],4,mode)
   fig2LaTeX(['Pre_Processing_05'],5,mode)
   fig2LaTeX(['Pre_Processing_06'],6,mode)
   fig2LaTeX(['Pre_Processing_07'],7,mode)
end