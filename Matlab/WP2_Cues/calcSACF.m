function [CUE, SET] = calcSACF(SIGNAL,CUE)
%calcSACF   Calculate summary auto-correlation function. 
%
%USAGE
%    [CUE, SET] = calcSACF(SIGNAL,CUE)
%
%INPUT ARGUMENTS
%      SIGNAL : signal structure
%         CUE : cue structure initialized by init_WP2
% 
%OUTPUT ARGUMENTS
%         CUE : updated cue structure
%         SET : updated cue settings (e.g., filter states)

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/03/05
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% GET INPUT DATA
% 
% 
% Input signal
data = SIGNAL.data;


%% GET CUE-RELATED SETINGS 
% 
% 
% Copy settings
SET = CUE.set;


%% COMPUTE SACF
% 
% 
% Integrate ACF across all auditory filters
data = squeeze(mean(data,3));


%% UPDATE CUE STRUCTURE
% 
% 
% Copy cue
CUE.data = data;
CUE.set.fsHz = SIGNAL.fsHz;