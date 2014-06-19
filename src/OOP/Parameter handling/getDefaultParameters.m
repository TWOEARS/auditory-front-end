function p = getDefaultParameters(fs,varargin)
%getDefaultParameter    Fetch a list of default parameters for a specific
%                       activity related to WP2 processing
%
%USAGE
%       p = getDefaultParameter(fs,fields)
%       p = getDefaultParameter(fs,field1,field2,...)
%
%INPUT ARGUMENTS
%      fs : Sampling frequency (needed for "processing" field)
%  fields : List of fields for which default parameters are required
%
%OUTPUT ARGUMENTS
%       p : Structure containing requested default parameters
%
%EXAMPLE:
% p = getDefaultParameter('plotting','processing'), will return the default
% parameters needed for generating a gammatone filterbank and for creating
% a plot.


% All parameters and their default values are stored in a file in the same
% folder as this m-file:
path = fileparts(mfilename('fullpath'));        % Directory
filename = [path filesep 'parameterInfo.mat'];  % Full file name

% Load the parameter info structure
load(filename,'pInfo');

% Get the different categories names
names = fieldnames(pInfo);

if nargin<2 || isempty(varargin)
    % Return all existing parameters if not specified otherwise
    cat = names;
elseif strcmp(varargin,'processing')
    % If asked for 'processing', then return all categories but plotting
    cat = names(~ismember(names,'plotting'));
else
    % Else, get only the categories specified as argument
    cat = varargin;
end

% Initialize output
p = struct;

% Loop on the categories
for ii = 1:size(cat,1)
    
    % Check that the category name is valid
    if ~isfield(pInfo,cat{ii})
        error('The name %s provided as argument is an invalid category name',cat{ii})
    end
    
    % Then fetch all parameters for that category
    sub_names = fieldnames(pInfo.(cat{ii}));             % Parameter names
    sub_names = sub_names(~ismember(sub_names,'label')); % Remove category label
    
    % Loop on the parameters for this category
    for jj = 1:size(sub_names,1)
        p.(sub_names{jj}) = pInfo.(cat{ii}).(sub_names{jj}).value;
    end
    
end

% Add sampling frequency
p.fs = fs;

% Add dependent parameters:
% - Vector of channels center frequencies
if isfield(p,'f_low') && isfield(p,'f_high') && isfield(p,'nERBs')
    p.cfHz = erb2freq(freq2erb(p.f_low):double(p.nERBs):freq2erb(p.f_high));
end


