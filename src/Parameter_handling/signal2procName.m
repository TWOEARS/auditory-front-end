function procName = signal2procName(signal)
%signal2procName    Returns name of last processor class for extracting a
%                   signal of a given name
%
%USAGE:
%   procName = signal2procName(signal)
%
%INPUT ARGUMENT:
%     signal : Valid signal name (string)
%
%OUTPUT ARGUMENT:
%   procName : Valid processor name
%
%EXAMPLE:
% signal2procName('innerhaircell') = 'IHCenvelopeProc'

if nargin<1
    signal = '';
end

switch signal
    case 'time'
        procName = 'identityProc';  % To be changed!
        
    case 'framedSignal'
        procName = 'framingProc';
        
    case 'gammatone'
        procName = 'gammatoneProc';
        
    case 'innerhaircell'
        procName = 'ihcProc';
        
    case 'ams_features'
        procName = 'amsProc';
        
    case 'crosscorrelation'
        procName = 'crosscorrelationProc';
     
    case 'autocorrelation'
        procName = 'autocorrelationProc';        
        
    case 'ratemap_magnitude'
        procName = 'ratemapProc';
    
    case 'ratemap_power'
        procName = 'ratemapProc';
        
    case 'onset_strength'
        procName = 'onsetProc';
        
    case 'offset_strength'
        procName = 'offsetProc';
        
    case 'itd'
        procName = 'itdProc';
        
    case 'ic'
        procName = 'icProc';
        
    case 'ild'
        procName = 'ildProc';
        
    case 'spectral_features'
        procName = 'spectralFeaturesProc';
        
    otherwise
        procName = '';
        warning('Signal named %s is invalid or not implemented yet.',signal)
        
end