function [FEAT,SET] = estSourceAzimuth(FEATURE,FEAT)

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
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

SET = FEAT.set;

%% GET AZIMUTH HISTOGRAM DATA
% 
% 
azimuthHist = FEATURE.data;
azimuthGrid = FEATURE.set.azimuth;


%% DETECT LOCAL PEAKS
% 
% 
peakIdx = findLocalPeaks(azimuthHist,'peaks',true);

% Rank peaks according to salience
[tmp,newIdx] = sort(azimuthHist(peakIdx),'descend'); %#ok

out(:,1) = azimuthGrid(peakIdx(newIdx));
out(:,2) = azimuthHist(peakIdx(newIdx));

FEAT.data = out;