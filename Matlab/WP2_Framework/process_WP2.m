function [SIGNALS,CUES,FEATURES,STATES] = process_WP2(earSignals,fsHz,STATES)
%process_WP2   Perform WP2 processing.
%
%USAGE
%   [SIGNALS,CUES,FEATURES,STATES] = process_WP2(earSignals,fsHz,STATES)
%
%INPUT PARAMETERS
%     earSignals : binaural signals [nSamples x 2]
%           fsHz : sampling frequency in Hertz
%         STATES : settings initialized by init_WP2
% 
%OUTPUT PARAMETERS
%        SIGNALS : multi-dimensional signal structure 
%           CUES : multi-dimensional cue structure 
%       FEATURES : multi-dimensional feature structure 
%         STATES : updated settings 

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2013
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/26
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!');
end


%% PERFORM SIGNAL EXTRACTION
% 
% 
% Perform WP2 signal computation
[SIGNALS,STATES] = process_WP2_signals(earSignals,fsHz,STATES);


%% PERFORM CUE EXTRACTION
% 
% 
% Perform WP2 cue computation
[CUES,STATES] = process_WP2_cues(SIGNALS,STATES);


%% PERFORM FEATURE EXTRACTION
% 
% 
% Perform WP2 feature extraction
[FEATURES,STATES] = process_WP2_features(CUES,STATES);


