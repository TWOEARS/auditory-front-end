function [azim,salience] = estimate_Azimuth(auditorySignals,fs,winSizeSec,N)
%estimate_Azimuth   Sound source localization.
%  
% A peripheral auditory processing stage is used to decomposes the input
% signals into individual frequency channels using a gammatone filterbank
% (gammaFB.m). The center frequencies are equally spaced on the equivalent
% rectangular bandwidth (ERB)-rate scale between fRange(1) and fRange(2).
% Sound source localization is performed by computing the cross-correlation
% function for each subband over short windows (winSec). The resulting
% 3-dimensional cross-correlation function CCF, which is a function of the
% number of lags, subbands and frames (nLags x nSubbands x nFrames) is
% mapped onto an azimuth grid (nAzimuth x nSubbands x nFrames) using the
% mapping function that has been created by calibrate_ITD_Subband.m. This
% mapping is performed for each subband separately. Then, this new CCF is
% integrated across all subbands and frames and the most prominent peaks
% are assumed to reflect the estimated sound source azimuth positions.    
% 
%USAGE
%    azimEst = estimate_Azimuth_Subband(binaural,fs)
%    azimEst = estimate_Azimuth_Subband(binaural,fs,winSec,N)
% 
%INPUT PARAMETERS
%   binaural : binaural input signal [nSamples x 2]
%         fs : sampling frequency in Hertz
%     winSec : frame size in seconds of the cross-correlation analysis
%              (default, winSec = 20E-3)
%          N : number of sound sources that should be localized
%              (default, N = inf)  
%
%OUTPUT PARAMETERS
%    azimEst : estimated azimuth of all N sources  [N x 1]
%    azimEst : salience of all N azimuth positions [N x 1]

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

% Set default parameter
if nargin < 3 || isempty(winSizeSec); winSizeSec = 20E-3; end


%% 2. INITIALIZE PARAMETERS
% 
% 
% Maximum time delay that should be considered
maxDelaySec = 1.25e-3;  

% Create mapping 
if ~exist('ITD2Azimuth_Mapping.mat','file')
    error('Can not find ITD2Azimuth mapping')
end

% Load ITD 2 Azimuth mapping
load('ITD2Azimuth_Mapping.mat');

% Framing parameters
winSize = 2 * round(winSizeSec * fs / 2);
hopSize = 2 * round(0.5 * winSizeSec * fs / 2);
overlap = winSize - hopSize;
window  = hann(winSize);

% Determine size of input
[nSamples,nFilter,nChannels] = size(auditorySignals); %#ok

% Calculate number of frames
nFrames = fix((nSamples-overlap)/hopSize);

% Relate maximum delay to samples (lags)                 
maxLag = ceil(maxDelaySec * fs);

% Number of azimuth directions
nAzim = length(mapping.azim);

% Allocate memory
CCF_Warped = zeros(nFilter,nFrames,nAzim);


%% 3. FRAME-BASED CROSS-CORRELATION ANALYSIS
% 
% 
% Loop over number of auditory filters
for ii = 1 : nFilter
    
    % Framing
    frames_L = frameData(auditorySignals(:,ii,1),winSize,hopSize,window,false);
    frames_R = frameData(auditorySignals(:,ii,2),winSize,hopSize,window,false);
    
    % Cross-correlation analysis
    [CCF,lags] = xcorrNorm(frames_L,frames_R,maxLag);
    
    % Warp cross-correlation function from ITD to azimuth 
    CCF_Warped(ii,:,:) = interp1(lags/fs,CCF,mapping.itd2azim(:,ii)).';
end

% Integrate warped cross-correlation pattern across frequency 
CCF_Warped_AF = transpose(squeeze(mean(CCF_Warped,1)));

% Integrate warped cross-correlation pattern across frames
CCF_Warped_Sum = mean(CCF_Warped_AF,2);


%% 5. FIND AZIMUTH
% 
% 
% Find azimuth positions
[azim,salience] = findAzimuth(CCF_Warped_Sum,mapping.azim,N);


%% 6. VISUALIZE RESULTS
% 
% 
% if nargout == 0 || bPlot(1)
%     
%     % Create time vector 
%     timeSec = (winSizeSec/2)*(1:size(CCF,2));
%     
%     % Find amplitude values corresponding to estimated source positions
%     peakVal = interp1(mapping.azim,CCF_Warped_Sum,azim);
%     
%     % Normalize correlation pattern for improve visualization
%     GCCNorm = CCF_Warped_AF ./ repmat(max(CCF_Warped_AF,[],1),[numel(mapping.azim) 1]);
%     
%     figure(100);clf;
%     subplot(3,1,1:2);
%     imagesc(mapping.azim,timeSec,GCCNorm.',[-1 1]);hold on;
%     title('Subband correlation pattern')
%     xlim(mapping.azim([1 end]))
%     xlabel('Azimuth (degree)')
%     ylabel('Time (s)')
%     hcb = colorbar;
%     hpos = get(hcb,'position');
%     hpos(1) = hpos(1) * 1.075;
%     hpos(2) = hpos(2) * 1.005;
%     hpos(3) = hpos(3) * 0.7125;
%     hpos(4) = hpos(4) * 0.99925;
%     set(hcb,'position',hpos);
%         
%     subplot(3,1,3)
%     hold on;
%     h1 = plot(azim,peakVal,'kx','MarkerSize',12,'LineWidth',2.5);
%     h2 = plot([bPlot(2:end); bPlot(2:end)],[-1E3 1E3],':');
%     set(h2,'color',[0.65 0.65 0.65],'linewidth',4)
%     hL = legend([h1(1) h2(1)],{'estimated azimuth' 'true azimuth'});
%     set(hL,'position',[0.8 0.3125 0.17 0.04]);
%     
%     h3 = plot(mapping.azim,CCF_Warped_Sum,'-');hold on;
%     set(h3,'color',[0.45 0.45 0.45],'linewidth',1.75)
%     xlim([-90 90])
%     
%     ylim([0.95*min(CCF_Warped_Sum) 1.25*max(peakVal)])
%     xlabel('Azimuth (degree)')
%     ylabel('Activity')
%     set(gca,'YTickLabel',[])
%        
%     colormap(1-fireprint);
% end