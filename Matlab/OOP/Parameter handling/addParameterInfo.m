function addParameterInfo(cat,name,default,description,catLabel)

%setParameterInfo   Add information regarding a new parameter in the file
%                   for parameter info
%
%USAGE:
%  addParameterInfo(cat,name,default,description)
%
%INPUT ARGUMENTS:
%         cat : Category to which the parameter belongs in (string)
%        name : EXACT name of the parameter (string)
%     default : Default value for the parameter
% description : Description of the parameter (string)
%
%NB: To be used for WP2 development only!

% Parameter handling directory
path = fileparts(mfilename('fullpath'));

% Parameter info file name
filename = 'parameterInfo.mat';

% Load the parameter info structure
load([path filesep filename],'pInfo');

% Check if category exists
if ~isfield(pInfo,cat)
    fprintf('Adding a new category : %s\n',cat)
    pInfo.(cat)=struct;
end

% Add the category description if none yet
if ~isfield(pInfo.(cat),'label')
    pInfo.(cat).label = catLabel;
end

% Check if parameter already exists
if ~isfield(pInfo.(cat),name)
    fprintf('Adding new parameter %s with ',name)
    pInfo.(cat).(name)=struct;
else
    fprintf('Changing parameter %s to ',name)
end

% Add the default value
try
    fprintf('default value %s : ',num2str(default))
end
pInfo.(cat).(name).value = default;

% And the parameter's description
fprintf('%s\n',description)
pInfo.(cat).(name).description = description;

% Save the modified structure
save([path filesep filename],'pInfo')