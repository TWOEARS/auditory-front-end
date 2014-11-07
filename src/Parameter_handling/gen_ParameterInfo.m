clear all
close all

% This script (re)populates the parameter info structure

% Re-initialize pInfo
pInfo = struct;

% Get correct path
path = fileparts(mfilename('fullpath'));

% Save the empty structure
save([path filesep 'parameterInfo.mat'],'pInfo')
clear pInfo

% Add all parameters

% Processing:
    % Time-domain framing processor
    addParameterInfo('fr','fr_wname','hamming','Window name descriptor (see window.m)','Time-domain signal framing processor')
    addParameterInfo('fr','fr_wSize',1024,'Window duration in samples')
    addParameterInfo('fr','fr_hSize',512,'Step size between windows in samples')

    % Gammatone filterbank
    addParameterInfo('gammatone','gt_lowFreqHz',80,'Lowest center frequency (Hz)','Gammatone filterbank')
    addParameterInfo('gammatone','gt_highFreqHz',8000,'Highest center frequency (Hz)')
    addParameterInfo('gammatone','gt_nERBs',1,'Distance between neighbor filters in ERBs')
    addParameterInfo('gammatone','gt_nChannels',[],'Number of channels')
    addParameterInfo('gammatone','gt_cfHz',[],'Vector of channels'' center frequencies in Hz')
    addParameterInfo('gammatone','gt_nGamma',4,'Gammatone rising slope order')
    addParameterInfo('gammatone','gt_bwERBs',1.018,'Bandwidth of the filters (ERBs)')
    addParameterInfo('gammatone','gt_bAlign',false,'Correction for filter alignment')

    % Inner hair-cell extraction
    addParameterInfo('ihc','ihc_method','dau','Inner hair-cell extraction method (''none'', ''halfwave'', ''fullwave'', ''square'', ''hilbert'', ''joergensen'', ''dau'', ''breebart'', ''berstein'')','Inner hair-cell extraction')

    % Amplitude modulation spectrogram features
    addParameterInfo('ams','ams_fbType','log','Filterbank type (''lin'' or ''log'')','Amplitude modulation spectrogram features')
    addParameterInfo('ams','ams_nFilters',[],'Requested number of modulation filters (integer)')
    addParameterInfo('ams','ams_lowFreqHz',4,'Lowest modulation center frequency (Hz)','Modulation filterbank')
    addParameterInfo('ams','ams_highFreqHz',1024,'Highest modulation center frequency (Hz)','Modulation filterbank')
    addParameterInfo('ams','ams_cfHz',[],'Vector of channels'' center frequencies in Hz')
    addParameterInfo('ams','ams_dsRatio',4,'Downsampling ratio of the envelope')
    addParameterInfo('ams','ams_wSizeSec',32E-3,'Window duration (s)')
    addParameterInfo('ams','ams_hSizeSec',16E-3,'Window step size (s)')
    addParameterInfo('ams','ams_wname','rectwin','Window name')
    
    % Interaural Level Difference (ILD)
    addParameterInfo('ild','ild_wname','hann','Window name','Interaural Level Difference')
    addParameterInfo('ild','ild_wSizeSec',20E-3,'Window duration (s)')
    addParameterInfo('ild','ild_hSizeSec',10E-3,'Window step size (s)')

    % Ratemap Extraction
    addParameterInfo('rm','rm_wname','hann','Window name','Ratemap extraction')
    addParameterInfo('rm','rm_wSizeSec',20E-3,'Window duration (s)')
    addParameterInfo('rm','rm_hSizeSec',10E-3,'Window step size (s)')
    addParameterInfo('rm','rm_scaling','power','Ratemap scaling (''power'' or ''magnitude'')')
    addParameterInfo('rm','rm_decaySec',8E-3,'Leaky integrator time constant (s)')

    % Onset strength
    addParameterInfo('ons','ons_maxOnsetdB',30,'Upper limit for onset value','Onset strength extraction')
    
    % Onset strength
    addParameterInfo('ofs','ofs_maxOffsetdB',30,'Upper limit for offset value','Offset strength extraction')
    
    % Transient mapping
    addParameterInfo('trm','trm_minStrengthDB',3,'Minimum transient strength for mapping','Transient mapping')
    addParameterInfo('trm','trm_minSpread',5,'Minimum spread of the transient over frequency channels')
    addParameterInfo('trm','trm_fuseWithinSec',30E-3,'Events within that period (in sec) are fused together')
    
    % Auto-correlation
    addParameterInfo('ac','ac_wname','hann','Window name','Auto-correlation')
    addParameterInfo('ac','ac_wSizeSec',20E-3,'Window duration (s)')
    addParameterInfo('ac','ac_hSizeSec',10E-3,'Window step size (s)')
    addParameterInfo('ac','ac_clipMethod','clp','Center clipping method (''clc'', ''clp'', or ''sgn'')')
    addParameterInfo('ac','ac_clipAlpha',0.6,'Threshold in center clipping (between 0 and 1)')
    addParameterInfo('ac','ac_K',2,'Exponent in auto-correlation')

    % Pitch
    addParameterInfo('pi','pi_rangeHz',[80 400],'Range in Hz for valid pitch estimation','Pitch estimation')
    addParameterInfo('pi','pi_confThres',0.7,'Threshold for pitch condidence measure (re. 1)')
    addParameterInfo('pi','pi_medianOrder',3,'Median order filter for pitch smoothing (integer)')
    
    % Cross-correlation
    addParameterInfo('cc','cc_wname','hann','Window name','Cross-correlation')
    addParameterInfo('cc','cc_wSizeSec',20E-3,'Window duration (s)')
    addParameterInfo('cc','cc_hSizeSec',10E-3,'Window step size (s)')
    addParameterInfo('cc','cc_maxDelaySec',1.1E-3,'Maximum delay in cross-correlation computation (s)')

    % Cross-correlation feature
    addParameterInfo('ccf','ccf_factor',3,'Downsampling factor for the lag vector (positive integer)','Cross-correlation feature')
    
    % Interaural coherence
    addParameterInfo('ic',[],[],[],'Interaural coherence')
    
    % Interaural time difference
    addParameterInfo('itd',[],[],[],'Interaural Time Difference')
    
    % Spectral features
    addParameterInfo('sf','sf_requests','all','List (cell array) of requested spectral features, type ''help SpectralFeaturesProc'' for a list','Spectral features')
    addParameterInfo('sf','sf_br_cf',1500,'Cutoff frequency for brightness computation')
    addParameterInfo('sf','sf_ro_perc',0.8,'Threshold (re. 1) for spectral rolloff computation')
    
% Plotting:
    addParameterInfo('plotting','ftype','Helvetica','Plots font name','Plot properties')
    addParameterInfo('plotting','fsize_label',12,'Labels font size')
    addParameterInfo('plotting','fsize_title',14,'Titles font size')
    addParameterInfo('plotting','fsize_axes',10,'Axes font size')
    addParameterInfo('plotting','color','b','Main plot color')
    addParameterInfo('plotting','colors',{'b','r','g','c'},'Multiple plot colors')
    addParameterInfo('plotting','linewidth_s',1,'Small linewidth')
    addParameterInfo('plotting','linewidth_m',2,'Medium linewidth')
    addParameterInfo('plotting','linewidth_l',3,'Large linewidth')

    addParameterInfo('plotting','colormap','jet','Colormap for time-frequency plots')
    addParameterInfo('plotting','bColorbar',1,'Boolean for displaying colorbar in time-frequency plots')
    addParameterInfo('plotting','dynrange',80,'Dynamic range for time-frequency plots (dB)')
    addParameterInfo('plotting','aud_ticks',[100 250 500 1000 2000 4000 8000 16000 32000],'Auditory ticks for ERB-based representations')
    addParameterInfo('plotting','wavPlotDS',3,'Decimation ratio for plotting undecimated wave plot representations')
    addParameterInfo('plotting','wavPlotZoom',5,'Zoom factor in wave plot representations')
    addParameterInfo('plotting','corPlotZoom',3,'Zoom factor in correlation wave plots')
    addParameterInfo('plotting','binaryMaskColor',[0 0 0],'Color for binary mask (in RGB value)')

