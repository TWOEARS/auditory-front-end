function [itd,SET] = calcITD(signal,SET)
%calcITD   Calculate interaural time differences (ITDs). 
%
%USAGE
%    itd = calcITD(xcf,P)
%
%INPUT ARGUMENTS
%   xcf  : cross-correlation pattern [nLags x nFrames x nFilter]
%      P : parameter structure
% 
%OUTPUT ARGUMENTS
%   ITD : interaural time difference in seconds [nFilter x nFrames]

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

% Determine input size
[nLags,nFrames,nFilter] = size(signal);

% Allocate memory
itd = zeros(nFilter,nFrames);

% Create lag vector
lags = (0:nLags-1).'-(nLags-1)/2;


%% COMPUTE ITD 
% 
% 
% Loop over number of auditory filters
for ii = 1:nFilter
    
    % Find maximum peak per frame
    [pIdx,rowIdx] = findLocalPeaks(signal(:,:,ii),'max',true); %#ok
    
    % Integer lag: Take most salient peaks
    lagInt = lags(rowIdx);
    
    % Fractional lag: Refine peak position by parabolic interpolation
    lagDelta = interpolateParabolic(signal(:,:,ii),rowIdx);
    
    % Final interaural time delay estimates
    itd(ii,:) = (lagInt + lagDelta)/SET.fsHz;
end