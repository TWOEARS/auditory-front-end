function SIGNALS = process_Signals(earSignals,fsHz,STATES)
%process_Signals   Create multi-dimensional signal representation.
%
%USAGE
%     SIGNALS = process_Signals(earSignals,STATES)
%
%INPUT PARAMETERS
%     binaural : binaural signals [nSamples x 2]
%       STATES : settings initialized by init_WP2
% 
%OUTPUT PARAMETERS
%      SIGNALS : Multi-dimensional signal representation 

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May © 2014
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
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Determine all required signal domains
domain = unique({STATES.cues.domain});

% Sanity check
if any(strcmp(domain,'crosscorrelation')) && ~any(strcmp(domain,'periphery'))
    % Cross-correlation is based on the periphery signals
    domain = [{'periphery'} domain];
end

% Number of different signal domains
nDomains = numel(domain);

% Array of structs for cue settings 
SIGNALS = repmat(cell2struct({[] [] []},{'domain' 'dim' 'data'},2),[nDomains 1]);
       
% Initialize domain counter
iD = 0;

% Short-cut
SIGNAL = STATES.signal;


%% PRE-PROCESS EAR SIGNALS
% 
% 
% Resample input signal
if fsHz ~= STATES.signal.fsHz 
    earSignals = resample(earSignals,fsHz,STATES.signal.fsHz);
end

% Normalize input
if STATES.signal.bNormRMS
    earSignals = earSignals / max(rms(earSignals));
end


%% TIME DOMAIN SIGNALS
% 
% 
% Increase counter
iD = iD + 1;

% Create time-domain representation
SIGNALS(iD).domain = 'time';
SIGNALS(iD).dim    = {'nSamples x [left right]'};
SIGNALS(iD).data   = earSignals;


%% CREATE PERIPHERAL AUDITORY SIGNALS
% 
% 
% Create peripheral auditory signals 
if any(strcmp('periphery',domain))
    % Increase counter
    iD = iD + 1;

    % Find input signal
    iI = strcmp({SIGNALS.domain},'time');
    
    SIGNALS(iD).domain = 'periphery';
    SIGNALS(iD).dim    = {'nSamples x nFilter x [left right]'};
    SIGNALS(iD).data   = PeripheralProcessing(SIGNALS(iI).data,fsHz,SIGNAL.periphery);
end


%% CREATE CROSS-CORRELATION REPRESENTATION
% 
% 
% Create peripheral auditory signals 
if any(strcmp('crosscorrelation',domain))
    % Increase counter
    iD = iD + 1;

    % Find input signal
    iI = strcmp({SIGNALS.domain},'periphery');
    
    SIGNALS(iD).domain = 'crosscorrelation';
    SIGNALS(iD).dim    = {'nLags x nFrames x nFilter'};
    SIGNALS(iD).data   = CrossCorrelationProcessing(SIGNALS(iI).data,SIGNAL);
end


%% ADAPTATION 


