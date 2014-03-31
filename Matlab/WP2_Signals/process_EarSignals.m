function [SIGNAL,SET] = process_EarSignals(INPUT,SIGNAL)
%process_EarSignals   Pre-process ear signals.
%
%USAGE
%   SIGNAL = process_EarSignals(INPUT,SIGNAL)
%
%INPUT PARAMETERS
%    INPUT : time domain signal structure 
%   SIGNAL : signal structure initialized by init_WP2
% 
%OUTPUT PARAMETERS
%   SIGNAL : modified signal structure
%      SET : updated signal settings (e.g., filter states)

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2013,2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
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
if fsHz ~= SET.fsHz 
    data = resample(data,SET.fsHz,fsHz);
    fsHz = SET.fsHz;
end


%% PRE-FILTER EAR SIGNALS
% 
% 
% Remove DC using a 50 Hz high-pass filter
if SET.bRemoveDC
    % Creamte DC-removal filter
    [b,a] = genFilter('removedc',fsHz);
    
    % Apply filter
    data = filter(b,a,data);
end


%% NORMALIZE EAR SIGNALS
% 
% 
% Normalize input
if SET.bNormRMS
    data = data / max(rms(data));
end


%% UPDATE SIGNAL STRUCTURE
% 
% 
% Copy signal
SIGNAL.data = data;
SIGNAL.fsHz = fsHz;
