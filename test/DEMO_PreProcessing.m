clear;
close all
clc


%% LOAD SIGNAL
% 
% 
% Load a signal
load('AFE_earSignals_16kHz');

% Replicate signals at a higher level
earSignals = cat(1,earSignals,5*earSignals)/5;

% Add a sinus @ 0.5 Hz
mixture = earSignals + repmat(0.5*sin(2*pi.*(0:size(earSignals,1)-1).' * 0.5/fsHz),[1 size(earSignals,2)]);


%% PLACE REQUEST AND CONTROL PARAMETERS
% 
% 
% Request time domain representation
requests = 'time';

% Cutoff frequency of DC removal filter
cutoffHzDC = 20;

% Pre-emphasis coefficient
coefPreEmphasis = 0.97;

% RMS integration constant
intTimeSecRMS = 500E-3;   

% Reference level 
refSPLdB = 100;

% Middle ear model
middleEarModel = 'jepsen';
            
% Plot properties
p_plot = genParStruct('fsize_label',10,'fsize_axes',10,'fsize_title',10);


%% Plot signal
% 
% 
% Instantiate signals
dataObj_ear = dataObject(earSignals,fsHz); % Original signal (for plotting purpose)
dataObj = dataObject(mixture,fsHz);       % Actual input signal

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
p = genParStruct('pp_bRemoveDC',true,'pp_cutoffHzDC',cutoffHzDC);

% Create a manager
mObj_DC = manager(dataObj,requests,p);

% Request processing
mObj_DC.processSignal;

% Plot the result
dataObj.plot([],p_plot,'bGray',1,'decimateRatio',3);
legend off, ylim([-1.5 1.5])
title('3. After DC removal')


%% Pre-whitening
% 
%
% Apply DC removal and pre-whitening
p = genParStruct('pp_bRemoveDC',true,'pp_cutoffHzDC',cutoffHzDC,...
                 'pp_bPreEmphasis',true,'pp_coefPreEmphasis',coefPreEmphasis);

% New data object
dataObj = dataObject(mixture,fsHz);

% Create a manager
mObj_PW = manager(dataObj,requests,p);

% Request processing
mObj_PW.processSignal;

% Plot the result
dataObj.plot([],p_plot,'bGray',1,'decimateRatio',3);
legend off, ylim([-1.5 1.5])
title('4. After pre-emphasis')


%% Perform AGC
%
%
% Apply DC removal, pre-whitening, and AGC (monaural)
pMono = genParStruct('pp_bRemoveDC',true,'pp_cutoffHzDC',cutoffHzDC,...
                     'pp_bPreEmphasis',true,'pp_coefPreEmphasis',coefPreEmphasis,...
                     'pp_bNormalizeRMS',true,'pp_intTimeSecRMS',intTimeSecRMS,...
                     'pp_bBinauralRMS',false);
             
% Apply DC removal, pre-whitening, and AGC (binaural)             
pBin = genParStruct('pp_bRemoveDC',true,'pp_cutoffHzDC',cutoffHzDC,...
                    'pp_bPreEmphasis',true,'pp_coefPreEmphasis',coefPreEmphasis,...
                    'pp_bNormalizeRMS',true,'pp_intTimeSecRMS',intTimeSecRMS,...
                    'pp_bBinauralRMS',true);
             
% New data objects
dataObjMono = dataObject(mixture,fsHz);
dataObjBin  = dataObject(mixture,fsHz);

% Create a managers
mObj_monoAGC = manager(dataObjMono,requests,pMono);
mObj_binAGC  = manager(dataObjBin,requests,pBin);

% Request processing
mObj_monoAGC.processSignal;
mObj_binAGC.processSignal;

% Plot the result
dataObjMono.plot([],p_plot,'bGray',1,'decimateRatio',3);
legend off, ylim([-18 18])
title('5. After monaural AGC')

dataObjBin.plot([],p_plot,'bGray',1,'decimateRatio',3);
legend off, ylim([-18 18])
title('6. After binaural AGC')



%% Middle ear filtering
% 
%
% Obtain the filter coefficients corresponding to the given model
if strcmp(middleEarModel, 'jepsen')
    pp_middleEarModel = 'jepsenmiddleear';
    meFilterPeakdB = 55.9986;       % dB to add for unity gain at peak
elseif strcmp(middleEarModel, 'lopezpoveda')
    meFilterPeakdB = 66.2888;
end

a = 1;
b = middleearfilter(fsHz, pp_middleEarModel);

% Apply filtering
dataL = filter(b, a, [dataObjBin.time{1}.Data(:)]);
dataR = filter(b, a, [dataObjBin.time{2}.Data(:)]);

% Compensation for unity gain (when DRNL is not used)
dataL = dataL * 10^(meFilterPeakdB/20);
dataR = dataR * 10^(meFilterPeakdB/20);

% New data object
dataObj = dataObject(cat(2,dataL,dataR),fsHz);

% dataObj.plot


% % Plot the result
% dataObj.plot([],p_plot,'bGray',1,'decimateRatio',3);
% legend off, ylim([-18 18])
% title('7. After middle ear filtering')


% figure;
% h = plot(timeSec(1:3:end),dataL(1:3:end,:));
% set(h(1),'color',[0 0 0]);
% set(h(2),'color',[0.5 0.5 0.5]);
% title('7. After middle ear filtering')
% xlabel('Time (s)')
% ylabel('Amplitude')
% xlim([timeSec(1) timeSec(end)])
% %     ylim([-18 18])




%% Level scaling to reference


% Get the pre-processed data from earlier stage
dataL = [dataObjBin.time{1}.Data(:) dataObjBin.time{2}.Data(:)];

% Obtain what the current calibration reference is
current_dboffset = dbspl(1);

% Adjust level corresponding to the given reference
dataL = gaindb(dataL, current_dboffset-refSPLdB);

% Simple scaling so no need for plotting



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