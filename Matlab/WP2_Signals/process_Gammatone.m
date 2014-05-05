function [SIGNAL,SET] = process_Gammatone(INPUT,SIGNAL)
%process_Gammatone   Apply gammatone filterbank.
%
%USAGE
%   [SIGNAL,SET] = process_Gammatone(INPUT,SIGNAL)
%
%INPUT PARAMETERS
%          INPUT : time domain signal structure 
%         SIGNAL : signal structure initialized by init_WP2
% 
%OUTPUT PARAMETERS
%         SIGNAL : modified signal structure
%            SET : updated signal settings (e.g., filter states)

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


%% GET INPUT DATA
% 
% 
% Input signal and sampling frequency
data = INPUT.data;
fsHz = INPUT.fsHz;


%% GET SIGNAL-RELATED SETINGS 
% 
% 
% Copy settings
SET = SIGNAL.set;


%% RESAMPLING
% 
% 
% Resample input signal, is required
if fsHz ~= SIGNAL.fsHz 
    data = resampleData(data,SIGNAL.fsHz,fsHz);
    fsHz = SIGNAL.fsHz;
end


%% DECOMPOSE INPUT INTO INDIVIDUAL FREQUENCY CHANNELS
% 
% 
% Determine size of input
[nSamples,nChannels] = size(data);

% Allocate memory
output = zeros(nSamples,SET.paramGT.nFilter,nChannels);

% Gammatone filtering
output(:,:,1) = gammaFB(data(:,1),fsHz,SET.paramGT);
output(:,:,2) = gammaFB(data(:,2),fsHz,SET.paramGT);


%% UPDATE SIGNAL STRUCTURE
% 
% 
% Copy signal
SIGNAL.data = output;

