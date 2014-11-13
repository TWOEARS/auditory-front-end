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
% Request spectral feature processor
requests = {'spectral_features'};

% Parameters of Gammatone processor
gt_nChannels  = 64;  
gt_lowFreqHz  = 80;
gt_highFreqHz = 8000;

% Parameters of innerhaircell processor
ihc_method    = 'dau';

% Parameters of ratemap processor
rm_wSizeSec  = 0.02;
rm_hSizeSec  = 0.01;
rm_scaling   = 'power';
rm_decaySec  = 8E-3;
rm_wname     = 'hann';

% Parameters 
par = genParStruct('gt_lowFreqHz',gt_lowFreqHz,'gt_highFreqHz',gt_highFreqHz,...
                   'gt_nChannels',gt_nChannels,'ihc_method',ihc_method,...
                   'ac_wSizeSec',rm_wSizeSec,'ac_hSizeSec',rm_hSizeSec,...
                   'rm_scaling',rm_scaling,'rm_decaySec',rm_decaySec,...
                   'ac_wname',rm_wname); 

               
%% PERFORM PROCESSING
% 
%                
% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% PLOT RESULTS
% 
% 
% Plot time domain signal
dObj.time{1}.plot

% Handle to the ratemap for plot overlay
rmap = dObj.ratemap{1};   

% Plot spectral features
dObj.spectral_features{1}.plot([],[],'overlay',rmap,'noSubPlots',1);


%% Save figures
if 0
    listOfFeatures = dObj.spectral_features{1}.fList;
    for ii = 1 : numel(listOfFeatures) + 1
        fig2LaTeX(['SpectralFeature_',num2str(ii)],ii,20);
    end
end

