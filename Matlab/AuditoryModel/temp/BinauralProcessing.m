function binMap = BinauralProcessing(periphery,STATES)
%
%USAGE
%        out = PeripheralProcessing(earsignals,fs,P)
%
%INPUT PARAMETERS
% auditorySignals : Peripheral auditory signals
%          STATES : parameter structure (initialized by init_WP2.m)
% 
%OUTPUT PARAMETERS
%        BinMap : Peripheral internal representations [nSamples x nFilter x 2]

%   Authors :  Nicolas Le Goff, Tobias May © 2013,2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%              nlg@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/31
%   v.0.2   2014/02/22 added FFT-based cross-correlation analysis
%   ***********************************************************************


%% 1. CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% INITIATE TIME FRAMING
% 
% 
% Determine size of input
[nSamples,nFilter,nChannels] = size(periphery); %#ok

% Short-cut
wSize = STATES.framing.winSize;
hSize = STATES.framing.hopSize;
win   = STATES.framing.window;

% Compute number of frames
nFrames = max(floor((nSamples-(wSize-hSize))/(hSize)),1);

% Initialize binaural map
binMap.process = STATES.binaural.processor;


%% BINAURAL PROCESSING
% 
% 
switch lower(STATES.binaural.processor)
    % A Cross-correlation function is used to compute binaural maps
    case 'xcorr'

        % Lags
        binMap.lags = (-STATES.binaural.maxLag:1:STATES.binaural.maxLag).';
        % Allocate memory
        binMap.map  = zeros(STATES.binaural.maxLag*2+1,nFrames,nFilter);
        binMap.ild  = zeros(1,nFrames,nFilter);

        % Loop over number of auditory filters
        for ii = 1 : nFilter
            
            % Framing
            frames_L = frameData(periphery(:,ii,1),wSize,hSize,win,false);
            frames_R = frameData(periphery(:,ii,2),wSize,hSize,win,false);
            
            % Cross-correlation analysis
            % binMap.map(:,:,ii) = xcorrNorm(frames_L,frames_R,STATES.binaural.maxLag);
            binMap.map(:,:,ii) = calcXCorr(frames_L,frames_R,STATES.binaural.maxLag,'coeff');
                        
            % Compute ILD
            binMap.ild(1,:,ii) = calcILD(frames_L,frames_R);
        end
                
    % A Equalization-Cancellation function is used to compute binaural maps
    case 'ec'
        
end
