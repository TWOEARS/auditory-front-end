function DEP = define_Dependencies
%define_Dependencies   Define feature, cue and signal dependencies. 
%
%USAGE
%            DEP = define_Dependencies
%
%INPUT ARGUMENTS
% 
%OUTPUT ARGUMENTS
%   DEP 
%      .signals  : signal-related dependencies
%      .cues     : cue-related dependencies
%      .features : feature-related dependencies

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/26
%   ***********************************************************************


%% DEFINE FEATURE DEPENDENCIES
% 
% 
% List of features
nIter = 1;

featureList{nIter} = 'ratemap_feature'; % Feature name
featureDEP1{nIter} = {};                % List of feature dependencies
featureDEP2{nIter} = {'ratemap'};       % List of cue dependencies

nIter = nIter + 1;

featureList{nIter} = 'azimuth';
featureDEP1{nIter}  = {};
featureDEP2{nIter}  = {'itd_xcorr'};

nIter = nIter + 1;

featureList{nIter} = 'azimuth_hist';
featureDEP1{nIter} = {'azimuth'};
featureDEP2{nIter} = {'ic_xcorr'};

nIter = nIter + 1;

featureList{nIter} = 'source_position';
featureDEP1{nIter} = {'azimuth_hist'};
featureDEP2{nIter} = {};


%% DEFINE CUE DEPENDENCIES
% 
% 
% List of cues
nIter = 1;
cueList{nIter} = 'rms';
cueDEP{nIter}  = {'time'};

nIter = nIter + 1;

cueList{nIter} = 'ratemap';
cueDEP{nIter}  = {'gammatone'};

nIter = nIter + 1;

cueList{nIter} = 'itd_xcorr';
cueDEP{nIter}  = {'crosscorrelation'};

nIter = nIter + 1;

cueList{nIter} = 'ic_xcorr';
cueDEP{nIter}  = {'crosscorrelation'};

nIter = nIter + 1;

cueList{nIter} = 'ild';
cueDEP{nIter}  = {'gammatone'};


%% DEFINE SIGNAL DEPENDENCIES
% 
% 
% List of signals
nIter = 1;

signalList{nIter} = 'time';
signalDEP{nIter}  = {'time'};

nIter = nIter + 1;

signalList{nIter} = 'gammatone';
signalDEP{nIter}  = {'time'};

nIter = nIter + 1;

signalList{nIter} = 'innerhaircell';
signalDEP{nIter}  = {'gammatone'};

nIter = nIter + 1;

signalList{nIter} = 'crosscorrelation';
signalDEP{nIter}  = {'innerhaircell'};

for ii = 1 : numel(signalList)
    DEP.signals.(signalList{ii}) = signalDEP{ii};
end
for ii = 1 : numel(cueList)
    DEP.cues.(cueList{ii}) = cueDEP{ii};
end
for ii = 1 : numel(featureList)
    DEP.features.(featureList{ii}){1} = featureDEP1{ii};
    DEP.features.(featureList{ii}){2} = featureDEP2{ii};
end