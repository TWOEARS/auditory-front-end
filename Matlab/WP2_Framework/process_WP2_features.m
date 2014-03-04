function [FEATURES,STATES] = process_WP2_features(CUES,STATES)
%process_WP2_features   Create multi-dimensional feature representation.
%
%USAGE
%   [FEATURES,STATES] = process_WP2_features(CUES,STATES)
%
%INPUT PARAMETERS
%         CUES : multi-dimensional cue structure 
%       STATES : settings initialized by init_WP2
% 
%OUTPUT PARAMETERS
%     FEATURES : multi-dimensional feature structure 
%       STATES : updated settings 

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


%% INITIALIZE FEATURE STRUCTURE
% 
% 
% Initialize feature struct
FEATURES = STATES.features;


%% EXTRACT FEATURES
%
% 
% Number of features to extract
nFeatures = numel(STATES.features);

% Loop over number of features
for ii = 1 : nFeatures
    
    % Select required features
    iDFeature = selectCells([FEATURES.name],FEATURES(ii).dependency{1});
    
    % Select required cues
    iDCue = selectCells([CUES(:).name],FEATURES(ii).dependency{2});
    
    % Perform feature processing
    if any(iDFeature) && any(iDCue)
        [FEATURES(ii).data,STATES.features(ii).set] = feval(FEATURES(ii).fHandle,CUES(iDCue),FEATURES(iDFeature),STATES.features(ii).set);
    elseif any(iDFeature)
        [FEATURES(ii).data,STATES.features(ii).set] = feval(FEATURES(ii).fHandle,FEATURES(iDFeature),STATES.features(ii).set);
    elseif any(iDCue)
        [FEATURES(ii).data,STATES.features(ii).set] = feval(FEATURES(ii).fHandle,CUES(iDCue),STATES.features(ii).set);        
    else
        error('%s: Cue ''%s'' does not exist.',mfilename.FEATURES(ii).cue);
    end
end


%% REMOVE FIELD NAMES
% 
% 
% Field entries in the FEATURE structure that should not be "visible"
rmFields = {'dependency'};

% Remove fields 
FEATURES = rmfield(FEATURES,rmFields);
