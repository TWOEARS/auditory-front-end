function out = estSourceAzimuth(FEATURE)

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
if nargin ~= 1
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Find active feature
bActive = selectCells({FEATURE.fHandle},mfilename);

% Detect feature settings
SET = FEATURE(bActive).set;

% Get azimuth histogram
azimuthHist = FEATURE(~bActive).data;
azimuthGrid = FEATURE(~bActive).set.azimuth;


%% DETECT LOCAL PEAKS
% 
% 
peakIdx = findLocalPeaks(azimuthHist,'peaks');

% Rank peaks according to salience
[tmp,newIdx] = sort(azimuthHist(peakIdx),'descend');

out(:,1) = azimuthGrid(peakIdx(newIdx));
out(:,2) = azimuthHist(peakIdx(newIdx));
