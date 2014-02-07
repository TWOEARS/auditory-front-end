function [azim,salience] = AzimuthExtraction(signals,states,N)

%
%USAGE
%        out = AzimuthExtraction(signals,states,N)
%
%INPUT PARAMETERS
%         signals : All signals
%         states  : All states
% 
%OUTPUT PARAMETERS
%    azimEst : estimated azimuth of all N sources  [N x 1]
%    azimEst : salience of all N azimuth positions [N x 1]

%   Authors :  Tobias May, Nicolas Le Goff © 2013,2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%              nlg@elektro.dtu.dk

%% SHORTCUT
auditorySignals = signals.auditorySignals;
fs = states.signal.fsHz;
winSizeSec = states.binaural.winSizeSec;

lags=signals.BinauralMap.Lags;
BinMap=signals.BinauralMap.Map;

%%
% Determine size of input
[nSamples,nFilter,~] = size(auditorySignals); 


% Framing parameters
winSize = 2 * round(winSizeSec * fs / 2);
hopSize = 2 * round(0.5 * winSizeSec * fs / 2);
overlap = winSize - hopSize;

% Calculate number of frames
nFrames = fix((nSamples-overlap)/hopSize);

% Create mapping 
if ~exist('ITD2Azimuth_Mapping.mat','file')
    error('Can not find ITD2Azimuth mapping')
end

% Load ITD 2 Azimuth mapping
load('ITD2Azimuth_Mapping.mat');

% Number of azimuth directions
nAzim = length(mapping.azim);

% Allocate memory
CCF_Warped = zeros(nFilter,nFrames,nAzim);

%% 3. FRAME-BASED CROSS-CORRELATION ANALYSIS
% 
% 
% Loop over number of auditory filters
for ii = 1 : nFilter
   
    % Warp cross-correlation function from ITD to azimuth 
    CCF_Warped(ii,:,:) = interp1(lags/fs,BinMap,mapping.itd2azim(:,ii)).';
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