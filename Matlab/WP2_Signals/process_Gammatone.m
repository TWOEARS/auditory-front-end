function [output,SET] = process_Gammatone(signal,SET)
%
%USAGE
%   [out,STATES] = process_Gammatone(earsignals,STATES)
%
%INPUT PARAMETERS
%   earsignals : binaural signals [nSamples x 2]
%       STATES : settings initialized by init_WP2
% 
%OUTPUT PARAMETERS
%          out : gammatone representations [nSamples x nFilters x 2]

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May, Nicolas Le Goff © 2013,2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%              nlg@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/25
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Determine size of input
[nSamples,nChannels] = size(signal);

% Allocate memory
output = zeros(nSamples,SET.paramGT.nFilter,nChannels);


%% DECOMPOSE INPUT INTO INDIVIDUAL FREQUENCY CHANNELS
% 
% 
% Gammatone filtering
output(:,:,1) = gammaFB(signal(:,1),SET.fsHz,SET.paramGT);
output(:,:,2) = gammaFB(signal(:,2),SET.fsHz,SET.paramGT);

