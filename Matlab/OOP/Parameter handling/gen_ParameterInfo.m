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

    % Gammatone filterbank
    addParameterInfo('gammatone','f_low',80,'Lowest center frequency (Hz)','Gammatone filterbank')
    addParameterInfo('gammatone','f_high',8000,'Highest center frequency (Hz)')
    addParameterInfo('gammatone','IRtype','IIR','Gammatone filter impulse response type (''IIR'' or ''FIR'')')
    addParameterInfo('gammatone','nERBs',1,'Distance between neighbor filters in ERBs')
    addParameterInfo('gammatone','n_gamma',4,'Gammatone rising slope order')
    addParameterInfo('gammatone','bwERBs',1.018,'Bandwidth of the filters (ERBs)')
    % addParameterInfo('gammatone','fb_decimation',1,'Decimation ratio of the filterbank')
    addParameterInfo('gammatone','durSec',128E-3,'Duration of FIR (s)')
    addParameterInfo('gammatone','bAlign',false,'Correction for filter alignment')

    % Inner hair-cell envelope extraction
    addParameterInfo('ihc','IHCMethod','dau','Inner hair-cell envelope extraction method (''none'', ''halfwave'', ''fullwave'', ''square'', ''hilbert'', ''joergensen'', ''dau'', ''breebart'', ''berstein'')','Inner hair-cell envelope extraction')

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

    % Auto-correlation
    addParameterInfo('ac','ac_wname','hann','Window name','Auto-correlation')
    addParameterInfo('ac','ac_wSizeSec',20E-3,'Window duration (s)')
    addParameterInfo('ac','ac_hSizeSec',10E-3,'Window step size (s)')
    addParameterInfo('ac','ac_clipMethod','clp','Center clipping method (''clc'', ''clp'', or ''sgn'')')
    addParameterInfo('ac','ac_clipAlpha',0.6,'Threshold in center clipping (between 0 and 1)')
    addParameterInfo('ac','ac_K',2,'Exponent in auto-correlation')

    % Cross-correlation
    addParameterInfo('cc','cc_wname','rectwin','Window name','Cross-correlation')
    addParameterInfo('cc','cc_wSizeSec',20E-3,'Window duration (s)')
    addParameterInfo('cc','cc_hSizeSec',10E-3,'Window step size (s)')
    addParameterInfo('cc','cc_maxDelaySec',1.1E-3,'Maximum delay in cross-correlation computation (s)')


% Plotting:
    addParameterInfo('plotting','ftype','Helvetica','Plots font name','Plot default properties')
    addParameterInfo('plotting','fsize_label',12,'Labels font size')
    addParameterInfo('plotting','fsize_title',14,'Titles font size')
    addParameterInfo('plotting','fsize_axes',10,'Axes font size')
    addParameterInfo('plotting','color','b','Main plot color')
    addParameterInfo('plotting','colors',{'b','r','g','c'},'Multiple plot colors')
    addParameterInfo('plotting','linewidth_s',1,'Small linewidth')
    addParameterInfo('plotting','linewidth_m',2,'Medium linewidth')
    addParameterInfo('plotting','linewidth_l',3,'Large linewidth')

    addParameterInfo('plotting','dynrange',80,'Dynamic range for time-frequency plots (dB)')
    addParameterInfo('plotting','aud_ticks',[100 250 500 1000 2000 4000 8000 16000 32000],'Auditory ticks for ERB-based representations')



