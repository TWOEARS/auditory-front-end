function BinMap = BinauralProcessing(auditorySignals,fs,P)
%
%USAGE
%        out = PeripheralProcessing(earsignals,fs,P)
%
%INPUT PARAMETERS
% auditorySignals : Peripheral auditory signals
%              fs : sampling frequency in Hertz
%               P : peripheral parameter structure (initialized by init_WP2.m)
% 
%OUTPUT PARAMETERS
%        BinMap : Peripheral internal representations [nSamples x nFilter x 2]

%   Authors :  Nicolas Le Goff © 2013,2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%              nlg@elektro.dtu.dk
%              
% 
%   History :  
%   v.0.1   2014/01/31
%   ***********************************************************************


%% 1. CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% INITIATE TIME FRAMING

% Maximum time delay that should be considered
maxDelaySec = P.maxDelaySec; %1.25e-3;  
winSizeSec = P.winSizeSec;

% Framing parameters
winSize = 2 * round(winSizeSec * fs / 2);
hopSize = 2 * round(0.5 * winSizeSec * fs / 2);
% overlap = winSize - hopSize;
window  = hann(winSize);

% Determine size of input
[nSamples,nFilter,nChannels] = size(auditorySignals); %#ok

% Calculate number of frames
% nFrames = fix((nSamples-overlap)/hopSize);

% Relate maximum delay to samples (lags)                 
maxLag = ceil(maxDelaySec * fs);


%% BINAURAL PROCESSING

switch P.BinProcType
    % A Cross-correlation function is used to compute binaural maps
    case 'Xcorr'
         % Loop over number of auditory filters
        for ii = 1 : nFilter
            
            % Framing
            frames_L = frameData(auditorySignals(:,ii,1),winSize,hopSize,window,false);
            frames_R = frameData(auditorySignals(:,ii,2),winSize,hopSize,window,false);
            
            % Cross-correlation analysis
            [CCF,lags] = xcorrNorm(frames_L,frames_R,maxLag);
            
        end                   
        BinMap.Map = CCF;
        BinMap.Lags = lags;
        
    
    % A Equalization-Cancellation function is used to compute binaural maps      
    case 'EC'
        
end
