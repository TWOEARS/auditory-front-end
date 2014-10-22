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
    addParameterInfo('gammatone','f_low',80,'Lowest center frequency (Hz)','Gammatone filterbank')
    addParameterInfo('gammatone','f_high',8000,'Highest center frequency (Hz)')
    addParameterInfo('gammatone','nERBs',1,'Distance between neighbor filters in ERBs')
    addParameterInfo('gammatone','nChannels',[],'Number of channels')
    addParameterInfo('gammatone','cfHz',[],'Vector of channels'' center frequencies in Hz')
    addParameterInfo('gammatone','IRtype','IIR','Gammatone filter impulse response type (''IIR'' or ''FIR'')')
    addParameterInfo('gammatone','n_gamma',4,'Gammatone rising slope order')
    addParameterInfo('gammatone','bwERBs',1.018,'Bandwidth of the filters (ERBs)')
    % addParameterInfo('gammatone','fb_decimation',1,'Decimation ratio of the filterbank')
    addParameterInfo('gammatone','durSec',128E-3,'Duration of FIR (s)')
    addParameterInfo('gammatone','bAlign',false,'Correction for filter alignment')

    % Inner hair-cell envelope extraction
    addParameterInfo('ihc','IHCMethod','dau','Inner hair-cell envelope extraction method (''none'', ''halfwave'', ''fullwave'', ''square'', ''hilbert'', ''joergensen'', ''dau'', ''breebart'', ''berstein'')','Inner hair-cell envelope extraction')

    % Amplitude modulation filterbank
    addParameterInfo('am','am_nFilters',15,'Requested number of filters (integer)','Amplitude modulation filterbank')
    addParameterInfo('am','am_range',[0 400],'Modulation frequency range (Hz)')
    addParameterInfo('am','am_win','rectwin','STFT/framing window type')
    addParameterInfo('am','am_bSize',512,'STFT/framing block size')
    addParameterInfo('am','am_olap',256,'STFT/framing overlap')
    addParameterInfo('am','am_type','fft','Filterbank type (''fft'' or ''filter'')')
    addParameterInfo('am','am_dsRatio',4,'Downsampling ratio')
    
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
    
    % Auto-correlation
    addParameterInfo('ac','ac_wname','hann','Window name','Auto-correlation')
    addParameterInfo('ac','ac_wSizeSec',20E-3,'Window duration (s)')
    addParameterInfo('ac','ac_hSizeSec',10E-3,'Window step size (s)')
    addParameterInfo('ac','ac_clipMethod','clp','Center clipping method (''clc'', ''clp'', or ''sgn'')')
    addParameterInfo('ac','ac_clipAlpha',0.6,'Threshold in center clipping (between 0 and 1)')
    addParameterInfo('ac','ac_K',2,'Exponent in auto-correlation')

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
    addParameterInfo('sf','sf_hfc_cf',4000,'Cutoff frequency for high-frequency content computation')
    addParameterInfo('sf','sf_ro_thres',0.8,'Threshold (re. 1) for spectral rolloff computation')
    
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



