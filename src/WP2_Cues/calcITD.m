function [CUE,SET] = calcITD(SIGNAL,CUE)
%calcITD   Calculate interaural time differences (ITDs). 
%
%USAGE
%   [CUE,SET] = calcITD(SIGNAL,CUE)
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


%% GET CUE-RELATED SETINGS 
% 
% 
% Copy settings
SET = CUE.set;


%% COMPUTE ITD 
% 
% 
% Determine input size
[nLags,nFrames,nFilter] = size(SIGNAL.data);

% Allocate memory
itd = zeros(nFilter,nFrames);

% Create lag vector
lags = (0:nLags-1).'-(nLags-1)/2;

% Loop over number of auditory filters
for ii = 1:nFilter
    
    % Find maximum peak per frame
    [pIdx,rowIdx] = findLocalPeaks(SIGNAL.data(:,:,ii),'max',false); %#ok
    
    % Integer lag: Take most salient peaks
    lagInt = lags(rowIdx);
    
    % Fractional lag: Refine peak position by parabolic interpolation
    lagDelta = interpolateParabolic(SIGNAL.data(:,:,ii),rowIdx);
    
    % Final interaural time delay estimates
    itd(ii,:) = (lagInt + lagDelta)/SIGNAL.fsHz;
end


%% UPDATE CUE STRUCTURE
% 
% 
% Copy signal
CUE.data = itd;