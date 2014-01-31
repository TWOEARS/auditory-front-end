function STATES = init_WP2(STATES)
%init_WP2   Initialize parameters for WP2 processing
%
%USAGE
%      STATES = init_WP2(STATES)
%
%INPUT PARAMETERS
%       STATES : settings
% 
%OUTPUT PARAMETERS
%     STATES : 

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2013
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/31
%   ***********************************************************************

%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin < 1 || nargin > 1
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% INITIALIZE PERIPHERAL PARAMETERS
% 
% 
% Short-cut
fs      = STATES.signal.fsHz;
fLowHz  = STATES.periphery.fLowHz;
fHighHz = STATES.periphery.fHighHz;
nErbs   = STATES.periphery.nErbs;
bAlign  = STATES.periphery.bAlign;


% Gammatone parameters 
STATES.periphery.gammatone = gammaFIR(fs,fLowHz,fHighHz,nErbs,bAlign);



%% INITIALIZE BINAURAL PARAMETERS
% 
% 
% Short-cut
winSec = STATES.binaural.winSizeSec;

% Learn mapping between ITD and sound source azimuth
calibrate_ITD(fs,winSec,STATES.periphery);



