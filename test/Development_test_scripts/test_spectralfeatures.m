% Develop spectral features

clear;
close all
clc


%% Load a signal

% Add paths
path = fileparts(mfilename('fullpath')); 
run([path filesep '..' filesep '..' filesep 'src' filesep 'startAuditoryFrontEnd.m'])

% Load a signal
load('TestBinauralCues');

% Take right ear signal
data = earSignals(:,2);     
% data = data + 10*rand(size(data));

fs = fsHz;
clear earSignals fsHz

% Request ratemap    
requests = {'spec_features'};

% Parameters
par = genParStruct('f_low',80,'f_high',8000,'nChannels',[]); 

% Create a data object
dObj = dataObject(data,fs);

% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();


%% Plot 
% 
% 
nFeatures = size(dObj.spec_features{1}.Data(:,:),2);
nSubplots = ceil(sqrt(nFeatures));

% Get ratemap 
rMap = dObj.ratemap_power{1}.Data(:,:);
fHz  = dObj.ratemap_power{1}.cfHz;

[nFrames,nFreq] = size(rMap);

% Generate a time axis
tSec = 0:1/dObj.spec_features{1}.FsHz:(size(dObj.spec_features{1}.Data(:,:),1)-1)/dObj.spec_features{1}.FsHz;
                
figure;
for ii = 1 : nFeatures
    ax(ii) = subplot(nSubplots,nSubplots,ii);
    switch dObj.spec_features{1}.fList{ii}
        case {'variation' 'hfc' 'brightness' 'flatness' 'entropy'}
            imagesc(tSec,(1:nFreq)/nFreq,10*log10(rMap'));axis xy;
            hold on;
            plot(tSec,dObj.spec_features{1}.Data(:,ii),'k--','linewidth',2)
            
            xlabel('Time (s)')
            ylabel('Normalized frequency')
        case {'irregularity' 'skewness' 'kurtosis' 'flux' 'decrease' 'crest'}
            plot(tSec,dObj.spec_features{1}.Data(:,ii),'k--','linewidth',2)
            xlim([tSec(1) tSec(end)])
            
            xlabel('Time (s)')
            ylabel('Feature magnitude')
            
        case {'rolloff' 'spread' 'centroid'}
            imagesc(tSec,fHz,10*log10(rMap'));axis xy;
            hold on;
            plot(tSec,dObj.spec_features{1}.Data(:,ii),'k--','linewidth',2)
            
            xlabel('Time (s)')
            ylabel('Frequency (Hz)')
        otherwise
            error('Feature is not supported!')
    end
    title(['Spectral ',dObj.spec_features{1}.fList{ii}])
end
linkaxes(ax,'x');



