function [ic,SET] = calcIC(signal,SET)
%calcITD   Calculate interaural correlation (IC). 
%
%USAGE
%   ic = calcIC(xcf,P)
%
%INPUT ARGUMENTS
%   xcf  : cross-correlation pattern [nLags x nFrames x nFilter]
%      P : parameter structure
% 
%OUTPUT ARGUMENTS
%   IC : interaural correlation  [nFilter x nFrames]

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/22
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
[nLags,nFrames,nFilter] = size(signal); %#ok

% Allocate memory
ic = zeros(nFilter,nFrames);


%% COMPUTE IC
% 
% 
% Loop over number of auditory filters
for ii = 1:nFilter
    
    % Find maximum peak per frame
    [pIdx,rowIdx] = findLocalPeaks(signal(:,:,ii),'max',true); %#ok
    
    % Determine IC by parabolic interpolation
    [lagDelta,ic(ii,:)] = interpolateParabolic(signal(:,:,ii),rowIdx); %#ok
end