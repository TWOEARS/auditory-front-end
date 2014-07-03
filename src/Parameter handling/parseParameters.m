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

% Get all default parameters
p_full = getDefaultParameters(p.fs);

% Overwrite each non-default values
for ii = 1:n_param
%     if isfield(p_full,names{ii})
        p_full.(names{ii}) = p.(names{ii});
%     else
%         warning('Ignored the unknown parameter name %s in the input parameter structure',names{ii})
%     end
end