function [SIGNALS,STATES] = process_WP2_signals(earSignals,fsHz,STATES)
%process_WP2_signals   Create multi-dimensional signal representation.
%
%USAGE
%   [SIGNALS,STATES] = process_WP2(earSignals,fsHz,STATES)
%
%INPUT PARAMETERS
%     binaural : binaural signals [nSamples x 2]
%         fsHz : sampling frequency in Hertz
%       STATES : settings initialized by init_WP2
% 
%OUTPUT PARAMETERS
%      SIGNALS : multi-dimensional signal structure
%       STATES : updated settings 

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/25
%   v.0.2   2014/03/07 modified handling of STATES
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!');
end


%% INITIALIZE SIGNAL STRUCTURE
% 
% 
% Initialize signal struct
SIGNALS = STATES.signals;


%% INITIALIZE TIME DOMAIN SIGNAL
% 
% 
% Select time domain signal
iDTime = strcmp([STATES.signals.domain],'time');

% Initialize time domain signal with ear signals
SIGNALS(iDTime).data = earSignals;
SIGNALS(iDTime).fsHz = fsHz;


%% CREATE MULTI-DIMENSIONAL SIGNAL REPRESENTATION
% 
% 
% Number of signals
nSignals = numel(STATES.signals);

% Loop over number of cues
for ii = 1 : nSignals
        
    % Select required signal domain
    iDSignal = selectCells([SIGNALS.domain],SIGNALS(ii).dependency);
    
    % Perform processing
    if any(iDSignal)
        [SIGNALS(ii),STATES.signals(ii).set] = feval(SIGNALS(ii).fHandle,SIGNALS(iDSignal),STATES.signals(ii));          
    else
        error('%s: SIGNAL ''%s'' does not exist.',mfilename,SIGNALS(ii).domain);
    end
end


%% REMOVE FIELD NAMES
% 
% 
% Field entries in the SIGNAL structure that should not be "visible"
rmFields = {'dependency'};

% Remove fields 
SIGNALS = rmfield(SIGNALS,rmFields);