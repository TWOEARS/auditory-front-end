function [sacf,SET] = calcSACF(acf,SET)
%calcSACF   Calculate summary auto-correlation function. 
%
%USAGE
%    itd = calcSACF(acf,P)
%
%INPUT ARGUMENTS
%    acf : auto-correlation pattern [nLags x nFrames x nFilter]
%      P : parameter structure
% 
%OUTPUT ARGUMENTS
%   sacf : summary auto-correlation pattern [nLags x nFrames x [left right]]

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


%% COMPUTE SACF
% 
% 
% Integrate ACF across all auditory filters
sacf = squeeze(mean(acf,3));