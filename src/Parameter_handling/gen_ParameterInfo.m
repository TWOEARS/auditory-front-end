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
    % Pre-processor
    addParameterInfo('preproc','pp_bRemoveDC',0,'Flag to activate DC-removal filter','Pre-processing')
    addParameterInfo('preproc','pp_cutoffHzDC',20,'Cutoff frequency (Hz) of DC-removal high-pass filter')
    addParameterInfo('preproc','pp_bPreEmphasis',0,'Flag to activate the pre-emphasis high-pass filter')
    addParameterInfo('preproc','pp_coefPreEmphasis',0.97,'Coefficient for pre-emphasis compensation (usually between 0.9 and 1)')
    addParameterInfo('preproc','pp_bNormalizeRMS',0,'Flag for activating automatic gain control')
    addParameterInfo('preproc','pp_bBinauralRMS',1,'Flag indicating the use of unified automatic gain control over left and right channel, for preserving channel relative differences.')
    addParameterInfo('preproc','pp_intTimeSecRMS',500E-3,'Time constant (s) for automatic gain control')
    addParameterInfo('preproc','pp_bLevelScaling',0,'Flag to apply level scaling to the given reference')
    addParameterInfo('preproc','pp_refSPLdB',100,'Reference dB SPL value to correspond to input signal RMS value of 1')
    addParameterInfo('preproc','pp_bMiddleEarFiltering',0,'Flag to apply middle ear filtering')
    addParameterInfo('preproc','pp_middleEarModel','jepsen','Middle ear filter model (jepsen or lopezpoveda)')
%     addParameterInfo('preproc','pp_bUnityComp',[],'Compensation to have maximum of unity gain for middle ear filter (automatically true for Gammatone and false for drnl filterbanks)')
    
    % Time-domain framing processor
%     addParameterInfo('fr','fr_wname','hamming','Window name descriptor (see window.m)','Time-domain signal framing processor')
%     addParameterInfo('fr','fr_wSize',1024,'Window duration in samples')
%     addParameterInfo('fr','fr_hSize',512,'Step size between windows in samples')

    % Filterbank parameters
    addParameterInfo('audfilterbank','fb_type','gammatone','Filterbank type (''gammatone'' or ''drnl'')','Auditory filterbank')
    addParameterInfo('audfilterbank','fb_lowFreqHz',80,'Lowest center frequency (Hz)','Gammatone filterbank')
    addParameterInfo('audfilterbank','fb_highFreqHz',8000,'Highest center frequency (Hz)')
    addParameterInfo('audfilterbank','fb_nERBs',1,'Distance between neighbor filters in ERBs')
    addParameterInfo('audfilterbank','fb_nChannels',[],'Number of channels')
    addParameterInfo('audfilterbank','fb_cfHz',[],'Vector of channels'' center frequencies in Hz')
    addParameterInfo('audfilterbank','fb_nGamma',4,'Gammatone rising slope order (Gammatone filterbank only)')
    addParameterInfo('audfilterbank','fb_bwERBs',1.018,'Bandwidth of the filters (ERBs) (Gammatone filterbank only)')
    addParameterInfo('audfilterbank','fb_bAlign',false,'Correction for filter alignment (Gammatone filterbank only)')
    addParameterInfo('audfilterbank','fb_mocIpsi', 1, 'Ipsilateral MOC feedback factor as DRNL nonlinear path gain (DRNL filterbank only)')
    addParameterInfo('audfilterbank','fb_mocContra', 1, 'Contralateral MOC feedback factor as DRNL nonlinear path gain (DRNL filterbank only)')
    addParameterInfo('audfilterbank','fb_model', 'CASP', 'DRNL implementation model (DRNL filterbank only)')
    
    % DRNL filterbank
%     addParameterInfo('drnl','drnl_lowFreqHz',80,'Lowest characteristic frequency (Hz)','DRNL filterbank')
%     addParameterInfo('drnl','drnl_highFreqHz',8000,'Highest characteristic frequency (Hz)')
%     addParameterInfo('drnl','drnl_nERBs',1,'Distance between neighboring characteristic frequency channels in ERBs')
%     addParameterInfo('drnl','drnl_nChannels',[],'Number of channels')
%     addParameterInfo('drnl','drnl_cfHz',[],'Vector of channels'' characteristic frequencies in Hz')


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
    
    % Adaptation loop
    addParameterInfo('adt','adpt_lim',10,'Adaptation loop overshoot limit', 'Adaptation loop')
    addParameterInfo('adt','adpt_mindB',0,'Adaptation loop lowest signal level (dB)')
    addParameterInfo('adt','adpt_tau',[0.005 0.050 0.129 0.253 0.500],'Adaptation loop time constants')
   
    % Interaural Level Difference (ILD)
    addParameterInfo('interld','ild_wname','hann','Window name','Interaural level difference')
    addParameterInfo('interld','ild_wSizeSec',20E-3,'Window duration (s)')
    addParameterInfo('interld','ild_hSizeSec',10E-3,'Window step size (s)')

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
    addParameterInfo('trm','trm_minStrengthdB',3,'Minimum transient strength for mapping','Transient mapping')
    addParameterInfo('trm','trm_minSpread',5,'Minimum spread of the transient over frequency channels')
    addParameterInfo('trm','trm_fuseWithinSec',30E-3,'Events within that period (in sec) are fused together')
    addParameterInfo('trm','trm_minValuedB',[],'Lower limit of the original representation, below which its transient will not be considered')
    
    % Auto-correlation
    addParameterInfo('autocor','ac_wname','hann','Window name','Auto-correlation')
    addParameterInfo('autocor','ac_wSizeSec',20E-3,'Window duration (s)')
    addParameterInfo('autocor','ac_hSizeSec',10E-3,'Window step size (s)')
    addParameterInfo('autocor','ac_clipMethod','clp','Center clipping method (''clc'', ''clp'', or ''sgn'')')
    addParameterInfo('autocor','ac_clipAlpha',0.6,'Threshold in center clipping (between 0 and 1)')
    addParameterInfo('autocor','ac_K',2,'Exponent in auto-correlation')

    % Pitch
    addParameterInfo('pi','pi_rangeHz',[80 400],'Range in Hz for valid pitch estimation','Pitch estimation')
    addParameterInfo('pi','pi_confThres',0.7,'Threshold for pitch condidence measure (re. 1)')
    addParameterInfo('pi','pi_medianOrder',3,'Median order filter for pitch smoothing (integer)')
    
    % Cross-correlation
    addParameterInfo('crosscor','cc_wname','hann','Window name','Cross-correlation')
    addParameterInfo('crosscor','cc_wSizeSec',20E-3,'Window duration (s)')
    addParameterInfo('crosscor','cc_hSizeSec',10E-3,'Window step size (s)')
    addParameterInfo('crosscor','cc_maxDelaySec',1.1E-3,'Maximum delay in cross-correlation computation (s)')

    % Cross-correlation feature
%     addParameterInfo('ccf','ccf_factor',3,'Downsampling factor for the lag vector (positive integer)','Cross-correlation feature')
    
    % Interaural coherence
    addParameterInfo('intercor',[],[],[],'Interaural coherence')
    
    % Interaural time difference
    addParameterInfo('intertd',[],[],[],'Interaural time difference')
    
    
    % Spectral features
    addParameterInfo('sf','sf_requests','all','List (cell array) of requested spectral features, type ''help SpectralFeaturesProc'' for a list','Spectral features')
    addParameterInfo('sf','sf_br_cf',1500,'Cutoff frequency for brightness computation')
    addParameterInfo('sf','sf_ro_perc',0.8,'Threshold (re. 1) for spectral rolloff computation')
    
    % Gabor features
    addParameterInfo('gb','gb_maxDynamicRangeDB',80,'Maximum dynamic range (dB) of input ratemap','Gabor features')
    
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
    addParameterInfo('plotting','binaryMaskColor',[0 0 0],'Color for binary mask (in RGB value)')

