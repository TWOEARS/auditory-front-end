function [FEATURES,STATES] = process_WP2_features(CUES,STATES)
%process_WP2_features   Perform WP2 feature processing
%
%USAGE
%      FEATURES = process_WP2_features(CUES,FEATURES)
%
%INPUT PARAMETERS
%         CUES : Multi-dimensional cue structure 
%     FEATURES : feature settings initialized by init_WP2
% 
%OUTPUT PARAMETERS
%     FEATURES : extracted signals (e.g. output of gammatone filterbank)

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May © 2013, 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/22
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% EXTRACT FEATURES
%
% 
% Number of features to extract
nFeatures = numel(STATES.features);

% Initialize feature struct
FEATURES = STATES.features;

% Loop over number of features
for ii = 1 : nFeatures
    
    % Select required cues
    iDCue = selectCells([CUES(:).name],FEATURES(ii).dependency{2});
    
    % Select required features
    iDFeature = selectCells([FEATURES.name],FEATURES(ii).dependency{1});
    
    % Perform feature processing
    if any(iDCue) && any(iDFeature)
        [FEATURES(ii).data,STATES.features(ii).set] = feval(FEATURES(ii).fHandle,CUES(iDCue),FEATURES(iDFeature),STATES.features(ii).set);
    elseif any(iDFeature)
        [FEATURES(ii).data,STATES.features(ii).set] = feval(FEATURES(ii).fHandle,FEATURES(iDFeature),STATES.features(ii).set);
    elseif any(iDCue)
        [FEATURES(ii).data,STATES.features(ii).set] = feval(FEATURES(ii).fHandle,CUES(iDCue),STATES.features(ii).set);        
    else
        error('%s: Cue ''%s'' does not exist.',mfilename.FEATURES(ii).cue);
    end
end



