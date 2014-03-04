function cues = calcBinauralCues(binaural_map,P)
% 
%USAGE
%    cues = calcBinauralCues(binaural_map,S)
%
%INPUT PARAMETERS
% 
%OUTPUT PARAMETERS
% 

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/21
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% COMPUTE BINAURAL CUES
% 
% 
% Select binaural processor
switch binaural_map.process
    case 'xcorr'

        % Compute interaural time difference
        [ITD,IC] = calcITD(binaural_map.map,binaural_map.lags,P.set.fsHz);
        
        % Copy ILDs
        ILD = permute(binaural_map.ild,[3 2 1]);
        
        % Accumulate binaural cues
        cues = cat(3,ITD,IC,ILD);
        
    otherwise
        error('Binaural process is not supported!')
end