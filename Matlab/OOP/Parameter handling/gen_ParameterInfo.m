function p_info = gen_ParameterInfo()
% 
% This function is not intended for use by non-developers of WP2


% Load list of default parameters with dummy sampling frequency
p_def = getDefaultParameters(1);

% Categories
cat = {'General',...
    'Gammatone filterbank',...
    'Inner hair-cell envelope',...
    'Interaural level difference (ILD)',...
    'Ratemap',...
    'Auto-correlation',...
    'Cross-correlation'};

% List of parameter names
names = fieldnames(p_def);

% Total number of parameters
n_par = size(names,1);

% Initialize a cell array for parameter info
p_info = cell(n_par,1);



% Loop on all parameters
for ii = 1:n_par
    
   % Initialize
%    p_info{ii} = struct;
   
   % Find suitable category
   switch names{ii}
       case {'fs'}
           p_info{ii}.category = 'General';
       case {'f_low','f_high','IRtype','nERBs','n_gamma','bwERBs','fb_decimation','durSec','bAlign'}
           p_info{ii}.category = 'Gammatone Filterbank';
       case {'IHCMethod'}
           p_info{ii}.category = 'Inner hair-cell envelope';
       case {'ild_wname','ild_wSizeSec','ild_hSizeSec'}
           p_info{ii}.category = 'Interaural level difference (ILD)';
       case {'rm_wname','rm_wSizeSec','rm_hSizeSec','rm_scaling','rm_decaySec'}
           p_info{ii}.category = 'Ratemap';
       case {'ac_wname','ac_wSizeSec','ac_hSizeSec','ac_clipMethod','ac_clipAlpha','ac_K'}
           p_info{ii}.category = 'Auto-correlation';
       case {'cc_wname','cc_wSizeSec','cc_hSizeSec','cc_maxDelaySec'}
           p_info{ii}.category = 'Cross-correlation';
       otherwise
           p_info{ii}.category = 'Misc.';
   end
   
   % 
    
    
end
