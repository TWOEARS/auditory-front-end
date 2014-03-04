function [azimHist,SET] = calcAzimuthHist(CUE,FEATURE,SET)

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/23
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Get azimuth estimation
azimuth = FEATURE.data;


%% IC-BASED AZIMUTH SELECTION
% 
% 
% Perform IC selection
if SET.bCueSelection
    % Only use "reliable" azimuth information according to IC
    azimuth(CUE.data < SET.thresIC) = NaN;
end


%% AZIMUTH HISTOGRAM
% 
% 
% Normalized azimuth histogram
azimHist = hist(azimuth(:),SET.azimuth).'/sum(isfinite(azimuth(:)));


