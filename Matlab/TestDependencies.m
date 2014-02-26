clear
close all
clc


%% DEFINE DEPENDENCIES
% 
% 
DEP = define_Dependencies;

% Cues to extract
listCue  = {};
% Features to extract
listFeat = {'source_position'};
% listFeat = {'ratemap_feature'};


%% UPDATE LIST
% 
% 
% Update list of required features, cues and signals
[features,cues,signals] = updateSigCueFeatList(listFeat,listCue,DEP)