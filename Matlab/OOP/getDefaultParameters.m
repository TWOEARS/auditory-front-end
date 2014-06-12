function p = getDefaultParameters(fs,varargin)
%getDefaultParameter    Get a list of default parameters for a specific
%                       activity related to WP2 processing
%
%USAGE
%       p = getDefaultParameter(fs,fields)
%       p = getDefaultParameter(fs,field1,field2,...)
%
%INPUT ARGUMENTS
%      fs : Sampling frequency (needed for "processing" field)
%  fields : List of fields for which defulat parameters are required
%
%OUTPUT ARGUMENTS
%       p : Structure containing requested default parameters
%
%EXAMPLE:
% p = getDefaultParameter('plotting','processing'), will return the default
% parameters needed for generating a gammatone filterbank and for creating
% a plot.



%% Checking input arguments

% List of available field names
available = {'plotting','processing'};

% Checking inputs
if ~isnumeric(fs)
    error('Incorrect input arguments')
end
if isempty(varargin)
    varargin = available;
end


% Sampling frequency is required for field "processing"
if isempty(fs)&&ismember('processing',varargin)
    error('The sampling frequency needs to be supplied for default "processing" parameters')
end

n = nargin-1;     % Number of requested fields

% Loop over all requested fields
for ii = 1:n
    if ~ismember(varargin{ii},available)
        % Then get the fields list as a single string
        list = []
        for ii = 1:size(available,2)-1
            list = [list available{ii} ', ']
        end
        list = [list available{end} '.'];
        error('Unknown field name. Available field names are %s',list)
    end
end

% Initialization
p = struct;


%% Plotting parameters
if ismember('plotting',varargin)
    
    % General parameters
    p.ftype = 'Helvetica';      % Plots font name
    p.fsize_label = 12;         % Labels font size 
    p.fsize_title = 14;         % Titles font size
    p.fsize_axes = 10;          % Axes font size
    
    % Time-domain representations
    p.color = 'b';              % Main color
    p.colors = {'b','r','g','c'};
                                % Vector of colors for multiple plots
    p.linewidth_s = 1;          % Small linewidth
    p.linewidth_m = 2;          % Medium linewidth
    p.linewidth_l = 3;          % Large linewidth
    
    % Time-frequency representations
    p.dynrange = 80;        % Dynamic range for spectrograms
    p.aud_ticks = [100 250 500 1000 2000 4000 8000 16000 32000];
                            % Auditory ticks for ERB-based representations
    
    
end

%% Processors parameters
if ismember('processing',varargin)
    
    % Signal parameters
    p.fs = fs;      
    
    % Gammatone filterbank attributes
    p.f_low = 80;               % Lowest frequency
    p.f_high = 8000;            % Highest frequency
    p.IRtype = 'IIR';           % Gammatone filter type
    p.nERBs = 1;                % Distance between neighbor filters in ERBs
    p.n_gamma = 4;              % Rising slope order
    p.bwERBs = 1.018;           % Bandwidth of the filters in ERBs
    p.fb_decimation = 1;        % Decimation ratio of the filters
    p.durSec = 128E-3;          % Duration of the FIR (s)
    p.bAlign = false;           % Correction for the filter alignment (not implemented yet)
    
    % Inner hair cell envelope
    p.IHCMethod = 'dau';        % IHC model
    
    % ILD extraction
    p.ild_wname = 'hann';       % Window name
    p.ild_wSizeSec = 20E-3;     % Window duration in seconds
    p.ild_hSizeSec = 10E-3;     % Window step size in seconds
    
    % Ratemap extraction
    p.rm_wname = 'hann';        % Window name
    p.rm_wSizeSec = 20E-3;      % Window duration in seconds
    p.rm_hSizeSec = 10E-3;      % Window step size in seconds
    p.rm_scaling = 'power';     % Ratemap scaling
    p.rm_decaySec = 8E-3;       % Leaky integrator time constant (sec)
    
    % Auto-correlation
    p.ac_wname = 'hann';        % Window name
    p.ac_wSizeSec = 20E-3;      % Window duration in seconds
    p.ac_hSizeSec = 10E-3;      % Window step size in seconds
    p.ac_clipMethod = 'clp';    % Center clipping method ('clc','clp','sgn')
    p.ac_clipAlpha = 0.6;       % Threshold in center clipping
    p.ac_K = 2;                 % Exponent in auto-correlation
    
    % Cross-correlation
    p.cc_wname = 'rectwin';     % Window name
    p.cc_wSizeSec = 20E-3;      % Window duration in seconds
    p.cc_hSizeSec = 10E-3;      % Window step size in seconds
    p.cc_maxDelaySec = 1.1E-3;  % Maximum delay in cross-correlation computation (s)
    
    % Interaural correlation
        % No additional parameters
    
    
    
    % "Dependent" parameters: to be moved to new function when updating
    % parameter handling
    p.cfHz = erb2freq(freq2erb(p.f_low):double(p.nERBs):freq2erb(p.f_high));
        % Vector of channels center frequencies
    
end

