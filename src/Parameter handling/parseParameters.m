function p_full = parseParameters(p)
%parseParameters    Add default values for missing parameters in a provided
%                   list of (non-default) parameters for WP2 processing
%
%USAGE
%  p_full = parseParameters(p)
%
%INPUT ARGUMENTS
%       p : Incomplete parameter structure
%
%OUTPUT ARGUMENTS
%  p_full : Complete parameter structure (completed with default values)
%
%SEE ALSO:
%


if isempty(p)||~isfield(p,'fs')
    error('Input parameter structure should at least include the sampling frequency')
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