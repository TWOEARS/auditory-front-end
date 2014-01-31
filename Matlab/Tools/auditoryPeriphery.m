function out = auditoryPeriphery(binaural,fs,P)
%auditoryPeriphery   Calculate frequency-dependent ITD2azimuth mapping
%
%USAGE
%        out = auditoryPeriphery(binaural,P)
%
%INPUT PARAMETERS
%   binaural : binaural signals [nSamples x 2]
%         fs : sampling frequency in Hertz
%          P : peripheral parameter structure (initialized by init_WP2.m)
% 
%OUTPUT PARAMETERS
%        out : auditory signal [nSamples x nFilter x 2]


%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2013
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/31
%   ***********************************************************************


%% 1. CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Determine size of input
[nSamples,nChannels] = size(binaural);


%% 2. DECOMPOSE INPUT INTO INDIVIDUAL FREQUENCY CHANNELS
% 
% 
if P.bCompute
    % Allocate memory
    out = zeros(nSamples,P.gammatone.nFilter,nChannels);
    
    % Gammatone filtering
    
    out(:,:,1) = gammaFB(binaural(:,1),fs,P.gammatone);
    out(:,:,2) = gammaFB(binaural(:,2),fs,P.gammatone);
else
    out = permute(binaural,[1 3 2]);
end


