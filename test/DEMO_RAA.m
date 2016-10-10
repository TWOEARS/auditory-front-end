clear;
close all
clc

%% LOAD SIGNAL
% 
% Load a signal
load('Test_signals/DEMO_Speech_Room_D');

% Create a data object based on the ear signals
dObj = dataObject(earSignals,fsHz);

time = (1:size(earSignals, 1)).'/fsHz;

%% PLACE REQUEST AND CONTROL PARAMETERS
% 
% 
% Request interaural time differences (ITDs)
requests = {'adaptation'};

% Parameters of preprocessing
pp_bLevelScaling = true;
pp_bMiddleEarFiltering = true;      % This may change to customised filter as in van Dorp Srhuitman thesis
pp_middleEarModel = 'jepsen';

% Parameters of the auditory filterbank processor
% Following van Dorp Schuitman's configuration
fb_type       = 'gammatone';
fb_lowFreqHz  = 167.7924;
fb_highFreqHz = 1836.4;
fb_nChannels  = 16;  

% Parameters of innerhaircell processor
ihc_method    = 'breebart';

% Parameters of adaptation processor
% ATH has not been applied (as in van Dorp Schuitman's model)
adpt_model = 'adt_vandorpschuitman';
% adpt_lim = 0;       % No overshoot limitation

% Summary of parameters 
par = genParStruct('pp_bLevelScaling', pp_bLevelScaling, ...
                   'pp_bMiddleEarFiltering', pp_bMiddleEarFiltering, ...
                   'pp_middleEarModel', pp_middleEarModel, ...
                   'fb_type',fb_type,'fb_lowFreqHz',fb_lowFreqHz,...
                   'fb_highFreqHz',fb_highFreqHz,'fb_nChannels',fb_nChannels,...
                   'ihc_method',ihc_method, 'adpt_model', adpt_model); 

               
%% PERFORM PROCESSING
% 
% Create a manager
mObj = manager(dObj,requests,par);

% Request processing
mObj.processSignal();

% Grab CF for future use
cfHz = dObj.filterbank{1}.cfHz;

%% BINAURAL PROCESSING - ITD CALCULATION

% ITD frame step size (hSizeSec) is 25 ms (= numSamples/itdNumFrames/fs)
% ITD frame length (wSizeSec): try 50 ms
w_wSizeSec = 0.05;
w_hSizeSec = 0.025;
wSize = 2*round(w_wSizeSec*fsHz/2);
hSize = round(w_hSizeSec*fsHz);
FsHzOut = 1/(w_hSizeSec);

% Specification of the double-sided exponential window
% w[n] = exp(-0.5*abs(n)/(tau_b*fs)) 
% This becomes "win" for the coming routines
tau_b = 0.03;       % time constant for the window function w[n]
n_win = (fix(-wSize/2):round(wSize/2)-1);
win = exp(-0.5*abs(n_win)/(tau_b*fsHz)).';

% Range of tau for ITD calculation
maxDelaySec = 700*1e-6;         % 700 us

in_l = dObj.adaptation{1}.Data(:);
in_r = dObj.adaptation{2}.Data(:);

[nSamples,nChannels] = size(in_l);

% How many frames are in the buffered input?
nFrames = floor((nSamples-(wSize-hSize))/hSize);

% Determine maximum lag in samples
maxLag = ceil(maxDelaySec*fsHz);

outITD = zeros(nFrames,nChannels);
timeITD = (0:nFrames-1).'/FsHzOut;

% Loop on the time frame
for ii = 1:nFrames
    % Get start and end indexes for the current frame
    n_start = (ii-1)*hSize+1;
    n_end = (ii-1)*hSize+wSize;

    % Loop on the channel
    for jj = 1:nChannels

        % Extract frame for left and right input
        frame_l = win.*in_l(n_start:n_end,jj);
        frame_r = win.*in_r(n_start:n_end,jj);

        % Compute the frames in the Fourier domain
        X = fft(frame_l,2^nextpow2(2*wSize-1));
        Y = fft(frame_r,2^nextpow2(2*wSize-1));

        % Compute cross-power spectrum
        XY = X.*conj(Y);

        % Back to time domain
        c = real(ifft(XY));

        % Adjust to requested maximum lag and move negative
        % lags upfront
        if maxLag >= wSize
            % Then pad with zeros
            pad = zeros(maxLag-wSize+1,1);
            c = [pad;c(end-wSize+2:end);c(1:wSize);pad];
        else
            % Else keep lags lower than requested max
            c = [c(end-maxLag+1:end);c(1:maxLag+1)];
        end
        
        nLags = length(c);

        % Create a lag vector
        lags = (0:nLags-1).'-(nLags-1)/2;

        % Find the peak in the discretized crosscorrelation
        [c_peak,i] = max(c);

        % Lag of most salient peak
        lagInt = lags(i);

        if i>1 && i<nLags
            % Then interpolate using neighbor points
            c_l = c(i-1);    % Lower neighbor
            c_u = c(i+1);    % Upper neighbor

            % Estimate "true" peak deviation through parabolic
            % interpolation
            delta = 0.5*(c_l-c_u)/(c_l-2*c_peak+c_u);

            % Store estimate
            outITD(ii,jj) = (lagInt + delta)/FsHzOut;

        else
            % Do not interpolate if the peak is at a boundary
            outITD(ii,jj) = lagInt/FsHzOut;
        end

    end

end


%% MONAURAL PROCESSING - LPF

% LPF 1st order, 8 Hz cutoff frequency (Sec. 3.5.1)
% 20ms time constant (Eq. A.23), 1st order difference equation
% y[n] = (1-exp(-1/(tau_e*fs))*x[n] + exp(-1/(tau_e*fs))*y[n-1]

tau_e = 20*1e-3;

bEnvExtFilter = 1-exp(-1/(tau_e*fsHz));
aEnvExtFilter = [1 -exp(-1/(tau_e*fsHz))];

PsiL = filter(bEnvExtFilter, aEnvExtFilter, in_l);
PsiR = filter(bEnvExtFilter, aEnvExtFilter, in_r);


%% PEAK / DIP DETECTION
% Constants for peak/dip detection
mu_psi = 7.49*1e-3;
mu_psi_dip = -1.33*1e-3;
T_min = 63.1*1e-3;

% use nSamples and nChannels
outDir_l  = zeros(nSamples, nChannels);
outDir_r  = zeros(nSamples, nChannels);

% Eq. 3.15 avg. absolute level
L_psi_l = 1/nSamples*sum(abs(in_l), 1); % dimension: (1 x length(cfHz))
L_psi_r = 1/nSamples*sum(abs(in_r), 1); 

% Eq. 3.14 threshold per frequency band
psi_min_l = mu_psi * L_psi_l;
psi_min_r = mu_psi * L_psi_r;

psi_min_dip_l = mu_psi_dip * L_psi_l;
psi_min_dip_r = mu_psi_dip * L_psi_r;

% Per frequency channel
for f=1:nChannels
    
    % Find time indices at which PsiL and PsiR are above threshold for peak
    idxAboveThreshold_l = find(PsiL(:, f) >= psi_min_l(f));
    idxAboveThreshold_r = find(PsiR(:, f) >= psi_min_r(f));
    
    % Group consecutive time indices of threshold-passing inputs
    consecIdxGroups_above_thr_l = RAA_group_indices(idxAboveThreshold_l);
    consecIdxGroups_above_thr_r = RAA_group_indices(idxAboveThreshold_r);
    % Groups of indices are returned as cells
    
    % Check if the duration of each index group exceeds T_min
    % Left and right separately
    for gg=1:size(consecIdxGroups_above_thr_l, 1)
        dur = (consecIdxGroups_above_thr_l{gg}(end) - consecIdxGroups_above_thr_l{gg}(1))/fsHz;
        % If this duration exceeds T_min then determine that group as a peak
        % and assign the corresponding input to the direct stream
        if(dur >= T_min)
            outDir_l(consecIdxGroups_above_thr_l{gg}, f) = ...
                PsiL(consecIdxGroups_above_thr_l{gg}, f);
        end
    end
    % Right channel
    for gg=1:size(consecIdxGroups_above_thr_r, 1)
        dur = (consecIdxGroups_above_thr_r{gg}(end) - consecIdxGroups_above_thr_r{gg}(1))/fsHz;
        % If this duration exceeds T_min then determine that group as a peak
        % and assign the corresponding input to the direct stream
        if(dur >= T_min)
            outDir_r(consecIdxGroups_above_thr_r{gg}, f) = ...
                PsiR(consecIdxGroups_above_thr_r{gg}, f);
        end
    end
   
    % Find time indices at which PsiL and PsiR are below threshold for dip
    idxBelowThreshold_l = find(PsiL(:, f) <= psi_min_dip_l(f));
    idxBelowThreshold_r = find(PsiR(:, f) <= psi_min_dip_r(f));
    
    % Group consecutive time indices of threshold-passing inputs
    consecIdxGroups_below_thr_l = RAA_group_indices(idxBelowThreshold_l);
    consecIdxGroups_below_thr_r = RAA_group_indices(idxBelowThreshold_r);
    % Groups of indices are returned as cells
        
    % Check if the duration of each index group exceeds T_min
    % Left and right separately
    for gg=1:size(consecIdxGroups_below_thr_l, 1)
        dur = (consecIdxGroups_below_thr_l{gg}(end) - consecIdxGroups_below_thr_l{gg}(1))/fsHz;
        % If this duration exceeds T_min then determine that group as a dip
        % and assign the corresponding input to the direct stream
        if(dur >= T_min)
            outDir_l(consecIdxGroups_below_thr_l{gg}, f) = ...
                PsiL(consecIdxGroups_below_thr_l{gg}, f);
        end
    end
    for gg=1:size(consecIdxGroups_below_thr_r, 1)
        dur = (consecIdxGroups_below_thr_r{gg}(end) - consecIdxGroups_below_thr_r{gg}(1))/fsHz;
        % If this duration exceeds T_min then determine that group as a dip
        % and assign the corresponding input to the direct stream
        if(dur >= T_min)
            outDir_r(consecIdxGroups_below_thr_r{gg}, f) = ...
                PsiR(consecIdxGroups_below_thr_r{gg}, f);
        end
    end       
        
end

% The rest of the input signals become the reverberant streams
outRev_l = PsiL - outDir_l;
outRev_r = PsiR - outDir_r;

% Comment as necessary%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot streams for test comparison
figure;
subplot(3, 1, 1)
plot(time, PsiL(:, 7));
hold on; plot(time, psi_min_l(7)*ones(length(time), 1));
hold on; plot(time, psi_min_dip_l(7)*ones(length(time), 1));
subplot(3, 1, 2)
plot(time, outDir_l(:, 7));
subplot(3, 1, 3)
plot(time, outRev_l(:, 7));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ITD SEGREGATION
% Compare ITD time indices to outDir and outRev indices

% 1s for nonzero time indices of L/R direct streams
idxL_dir = (outDir_l ~= 0);
idxR_dir = (outDir_r ~= 0);
zeta_DIR_t = idxL_dir+idxR_dir;
% zeta_DIR_t will be
% 0: for totally reverberant part
% 1: for parts with only left or right is in direct stream
% 2: for totally direct part
zeta_DIR_t = zeta_DIR_t/2;
% Now zeta_DIR_t will be 0, 0.5, or 1

% Allocate memory for zeta_DIR in ITD TIME FRAMES
zeta_DIR_itd = zeros(nFrames, nChannels);

% % ITD segregation method #1 (Ryan)
% % Run through zeta_DIR_t by ITD frames again
% for ii = 1:nFrames
%     % Get start and end indices for the current frame
%     % ITD frame length in the representation is hSize
%     n_start = (ii-1)*hSize+1;
%     n_end = ii*hSize;
%     
%     % Take one frame from zeta_DIR_t
%     frame_zeta_DIR = zeta_DIR_t(n_start:n_end, :);
%     % Equivalent to calculating the ratio of non-zero parts within frame
%     temp = frame_zeta_DIR .* ones(size(frame_zeta_DIR))/hSize;
%     % ratios of 0s, 0.5s, and 1s within the frame are multiplied by the
%     % actual zeta values
%     zeta_DIR_itd(ii, :) = sum(temp, 1);
% end

% ITD segregation method #2 (Original)
% Run through zeta_DIR_t by ITD frames again
for ii = 1:nFrames
    % Get start indices for the current frame
    % ITD frame length in the representation is hSize
    n_start = (ii-1)*hSize+1;
    
    % Check the centre of the frame - hSize/2? or wSize/2?
    % wSize/2 seems to make more sense, because
    % the centre of the frame was weighted the most in ITD calculation
    % (by the windowing process)
    % resample zeta_DIR_t at the time indices at centres of frames
    zeta_DIR_itd(ii, :) = ...
        zeta_DIR_t(n_start + round(wSize/2), :);
    
end

% ITD_DIR and ITD_REV calculation (eqs. 3.17 and 3.18)
outITD_DIR = zeta_DIR_itd.*outITD;
outITD_REV = outITD - outITD_DIR;



