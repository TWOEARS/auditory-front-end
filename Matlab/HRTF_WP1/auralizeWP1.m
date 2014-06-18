function out = auralizeWP1(audio,fsHz,azimuth)

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/24
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

persistent PER_irs PER_config

config    = SFS_config;
config.fs = fsHz;

if isempty(PER_config) || isequal(config,PER_config)
 
    irs  = read_irs('QU_KEMAR_anechoic_3m.mat',config);

    % Copy IRs to persistent memory
    PER_irs    = irs;
    PER_config = config;
else
    irs = PER_irs;
end

% Number of audio files
[nSamples,nSources] = size(audio);

% Allocate memory
out = [];

% Loop over number of audio files
for ii = 1 : nSources
    
    if azimuth(ii) <= 180; azimuth(ii) = -azimuth(ii); end
    
    % Read out IR
    ir = get_ir(irs,[rad(azimuth(ii)) 0 3]);
    
    % Spatialize signal using HRTF processing
    if isempty(out)
        out = auralize_ir(ir,audio(:,ii),1,config);
    else
        out = out + auralize_ir(ir,audio(:,ii),1,config);
    end
end






