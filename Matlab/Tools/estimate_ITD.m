function [itd,lags] = estimate_ITD(periphery,fs,winSec,N)
%estimate_ITD_Subband   Subband ITD estimation.
%
% The interaural time difference (ITD) is estimated from binaural signals.
% A peripheral auditory processing stage is used to decomposes the input 
% signals into individual frequency channels using a gammatone filterbank
% (gammaFB.m). The center frequencies are equally spaced on the equivalent
% rectangular bandwidth (ERB)-rate scale between fRange(1) and fRange(2).
% Then, the cross-correlation function (CCF) is computed for each subband
% over short time frames (winSec). The resulting 3-dimensional
% cross-correlation function, which is a function of the number of lags,
% subbands and frames (nLags x nSubbands x nFrames), is integrated
% across time frames and the most prominent peaks are assumed to reflect
% the estimated ITDs in each subband for N sources.          
% 
%USAGE
%    [itd,lags] = estimate_ITD_Subband(binaural,fs)
%    [itd,lags] = estimate_ITD_Subband(binaural,fs,winSec,N)
%
%INPUT PARAMETERS
%   binaural : peripheral signal [nSamples x nFilter x 2]
%         fs : sampling frequency in Hertz
%     winSec : frame size in seconds of the cross-correlation analysis
%              (default, winSec = 20E-3)
%          N : number of sources that should be localized (default, N = 1) 
%
%OUTPUT PARAMETERS
%        itd : subband-based ITD estimates of all N sources [nSubbands x N]
%       lags : time lags over which the CCF is computed

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2013
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/31
%   ***********************************************************************


%% 1. CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 4
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default parameters
if nargin < 3 || isempty(winSec); winSec = 20E-3; end
if nargin < 4 || isempty(N);      N      = 1;     end


%% 2. INITIALIZE PARAMETERS
% 
% 
% Maximum time delay in seconds that is considered
maxDelaySec = 1.25E-3;

% Framing parameters
winSize = 2 * round(winSec * fs / 2);
hopSize = 2 * round(0.5 * winSec * fs / 2);
window  = hann(winSize);

% Relate maximum delay to samples (lags)                 
maxLag = ceil(maxDelaySec * fs);

% Number of auditory filters
nFilter = size(periphery,2);

% Allocate memory
itd = zeros(nFilter,N);


%% 3. FRAME-BASED CROSS-CORRELATION ANALYSIS
% 
% 
% Loop over number of auditory filters
for ii = 1 : nFilter
    
    % Framing
    frames_L = frameData(periphery(:,ii,1),winSize,hopSize,window,false);
    frames_R = frameData(periphery(:,ii,2),winSize,hopSize,window,false);
    
    % Cross-correlation analysis to estimate ITD
    [CCF,lags] = xcorrNorm(frames_L,frames_R,maxLag);
    
    % Integrate cross-correlation pattern across all frames
    CCFsum = mean(CCF,2);

    % Estimate interaural time delay 
    itd(ii,:) = findITD(CCFsum,fs,lags,N);
end