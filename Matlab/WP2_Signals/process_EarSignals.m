function [data,SET] = process_EarSignals(data,SET)
%
%USAGE
%   [earSignals,STATES] = PeripheralProcessing(earSignals,STATES)
%
%INPUT PARAMETERS
%   earSignals : ear signals [nSamples x 2]
%       STATES : settings initialized by init_WP2
% 
%OUTPUT PARAMETERS
%   earSignals : ear signals [nSamples x 2]

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


%% PRE-PROCESS EAR SIGNALS
% 
% 
% Normalize input
if SET.bNormRMS
    data = data / max(rms(data));
end
