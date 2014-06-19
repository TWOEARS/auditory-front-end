function [CUE,SET] = calcIC(SIGNAL,CUE)
%calcITD   Calculate interaural correlation (IC). 
%
%USAGE
%   [CUE,SET] = calcIC(SIGNAL,CUE)
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


%% GET CUE-RELATED SETINGS 
% 
% 
% Copy settings
SET = CUE.set;


%% COMPUTE IC
% 
% 
% Determine input size
[nLags,nFrames,nFilter] = size(SIGNAL.data); %#ok

% Allocate memory
ic = zeros(nFilter,nFrames);

% Loop over number of auditory filters
for ii = 1:nFilter    
    % Find maximum peak per frame
    [pIdx,rowIdx] = findLocalPeaks(SIGNAL.data(:,:,ii),'max',false); %#ok
    
    % Determine IC by parabolic interpolation
    [lagDelta,ic(ii,:)] = interpolateParabolic(SIGNAL.data(:,:,ii),rowIdx); %#ok
end


%% UPDATE CUE STRUCTURE
% 
% 
% Copy signal
CUE.data = ic;