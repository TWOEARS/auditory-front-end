function [listFeatureNew,listCuesNew,listSignalNew] = updateSigCueFeatList(listFeat,listCues,DEP)

% Update feature list to consider proper order of processing

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/23
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

listCues = unique(listCues);
listFeat = unique(listFeat);

% Extract full list of supported cues and features
allCues = fieldnames(DEP.cues);
allFeat = fieldnames(DEP.features);

% Check if all cues are supported
msg = verifyList(listCues,allCues);

if ~isempty(msg)
    error('CUES %s are not supported.',msg);
end

% Check if all features are supported
msg = verifyList(listFeat,allFeat);

if ~isempty(msg)
    error('FEATURES %s are not supported.',msg);
end

listFeatureNew = updateFeatureList(listFeat,DEP);
listCuesNew    = updateCueList(listFeatureNew,listCues,DEP);
listSignalNew  = updateSignalList(listCuesNew,DEP);




