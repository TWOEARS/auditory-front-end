function azimHist = calcAzimuthHist(CUE,FEATURE)

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
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Find active feature
bActive = selectCells({FEATURE.fHandle},mfilename);

% Detect feature settings
SET = FEATURE(bActive).set;

% Get azimuth estimation
azimuth = FEATURE(~bActive).data;


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


