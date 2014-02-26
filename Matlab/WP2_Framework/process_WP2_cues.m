function [CUES,STATES] = process_WP2_cues(SIGNALS,STATES)
%process_WP2_cues   Perform WP2 processing
%
%USAGE
%   [SIGNALS,CUES] = process_WP2(earSignals,STATES)
%
%INPUT PARAMETERS
%     binaural : binaural signals [nSamples x 2]
%         fsHz : sampling frequency in Hertz
%       STATES : settings initialized by init_WP2
% 
%OUTPUT PARAMETERS
%      SIGNALS : Multi-dimensional signal structure
%         CUES : Multi-dimensional cue structure
%       STATES : Settings 

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, Nicolas Le Goff © 2013, 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%              nlg@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/31
%   v.0.2   2014/02/21 added modular cue extraction structure
%   v.0.3   2014/02/21 added STATES to output (for block-based processing)
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!');
end


%% EXTRACT CUES
%
% 
% Number of cues
nCues = numel(STATES.cues);

% Initialize cue struct
CUES = STATES.cues;

% Loop over number of cues
for ii = 1 : nCues
    
    % Select proper domain
    iDCue = strcmp([SIGNALS.domain],CUES(ii).dependency);
    
    % Perform processing
    if any(iDCue)
        [CUES(ii).data,STATES.cues(ii).set] = feval(CUES(ii).fHandle,SIGNALS(iDCue).data,STATES.cues(ii).set);          
    else
        error('%s: Domain ''%s'' does not exist.',mfilename,CUES(ii).domain);
    end
end

