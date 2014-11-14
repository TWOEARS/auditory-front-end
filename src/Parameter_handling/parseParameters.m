function p_full = parseParameters(p,request)
%parseParameters    Add default values for missing parameters in a provided
%                   list of (non-default) parameters for Two!Ears Auditory
%                   Front-End processing
%
%USAGE
%  p_full = parseParameters(p)
%  p_full = parseParameters(p,request)
%
%INPUT ARGUMENTS
%       p : Incomplete parameter structure
% request : Optional request name. Will then ensure that the returned parameters are
%           compatible with that request (e.g., spectral features computation need
%           rm_scaling = 'power').
%
%OUTPUT ARGUMENTS
%  p_full : Complete parameter structure (completed with default values)


if isempty(p)||~isfield(p,'fs')
    error('Input parameter structure should at least include the sampling frequency')
end

if nargin < 2
    request = '';
end

% Get the names of all fields in p
names = fieldnames(p);

% How many non-default parameters are specified in p?
n_param = size(names,1);

% Get all default parameters, with special care for the gammatone
% filterbank
if isfield(p,'cfHz')
    if ~isempty(p.cfHz)
        p_full = getDefaultParameters(p.fs,'no_gammatone'); 
    else
        p_full = getDefaultParameters(p.fs);
    end
elseif isfield(p,'nChannels')
    if ~isempty(p.nChannels)
        p_full = getDefaultParameters(p.fs,'no_gammatone'); 
    else
        p_full = getDefaultParameters(p.fs);
    end
else
    p_full = getDefaultParameters(p.fs);
end

% Overwrite each non-default values
for ii = 1:n_param
    p_full.(names{ii}) = p.(names{ii});
end

% Override some parameters depending on request
switch request
    case ''
        % Do nothing
        
    case 'spectral_features'
        if ~strcmp(p_full.rm_scaling,'power')
            p_full.rm_scaling = 'power';
            warning('Spectral features are based on power-scaled ratemap. Changing the ratemap scaling in the request from magnitude to power.')
        end
        
    case {'onset_strength' 'offset_strength' 'onset_map' 'offset_map'}
        if ~strcmp(p_full.rm_scaling,'power')
            p_full.rm_scaling = 'power';
            warning('Onset/offset detection is based on power-scaled ratemap. Changing the ratemap scaling in the request from magnitude to power.')
        end
        
    case 'gabor'
        if ~strcmp(p_full.rm_scaling,'power')
            p_full.rm_scaling = 'power';
            warning('Gabor feature extraction is based on power-scaled ratemap. Changing the ratemap scaling in the request from magnitude to power.')
        end
        
        if p_full.rm_hSizeSec ~= 10E-3
            p_full.rm_hSizeSec = 10E-3;
            warning('Gabor feature extraction is based on a given window step-size for ratemaps. Fixing the window size to 10ms.')
        end
        
    
end


% Override some parameters depending on request dependencies,
% Add parameters not controlled by the user

% Compensation for middle-ear filtering
if isfield(p_full,'fb_type')
    switch p_full.fb_type
        case 'gammatone'
            p_full.pp_bUnityComp = 1;
        case 'drnl'
            p_full.pp_bUnityComp = 0;
            if ~p_full.pp_bMiddleEarFiltering
                p_full.pp_bMiddleEarFiltering = true;
                warning('Middle ear filtering pre-processing is mandatory when using DRNL filterbank. Switching it on.')
            end
            if ~p_full.pp_bLevelScaling
                p_full.pp_bLevelScaling = true;
                warning('Level scaling pre-processing is mandatory when using DRNL filterbank. Switching it on.')
            end
    end
end
end