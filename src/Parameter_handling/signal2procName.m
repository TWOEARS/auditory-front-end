function procName = signal2procName(signal,p)
%signal2procName    Returns name of last processor class for extracting a
%                   signal of a given name
%
%USAGE:
%   procName = signal2procName(signal,p)
%
%INPUT ARGUMENT:
%     signal : Valid signal name (string)
%          p : Parameter structure (used when multiple processor can generate a given
%          representation, e.g. for 'filterbank')
%
%OUTPUT ARGUMENT:
%   procName : Valid processor name
%
%EXAMPLE:
% signal2procName('innerhaircell') = 'IHCenvelopeProc'

if nargin<1
    signal = '';
end

% Temporary error before removal
error('signal2procName was deprecated and should not be used anymore')

switch signal
    case 'time'
        procName = 'preProc';
        
    case 'framedSignal'
        procName = 'framingProc';
        
    case 'filterbank'
        procName = 'gammatoneProc';
%         switch p.fb_type
%             case 'gammatone'
%                 procName = 'gammatoneProc';
%             case 'drnl'
%                 procName = 'drnl';
%             otherwise
%                 error('Incorrect filterbank type name.')
%         end
        
    case 'innerhaircell'
        procName = 'ihcProc';

    case 'adaptation'
        procName = 'adaptationProc';  
        
    case 'ams_features'
        procName = 'amsProc';
        
    case 'crosscorrelation'
        procName = 'crosscorrelationProc';
     
    case 'autocorrelation'
        procName = 'autocorrelationProc';        
        
    case 'ratemap'
        procName = 'ratemapProc';
        
    case 'onset_strength'
        procName = 'onsetProc';
        
    case 'onset_map'
        procName = 'transientMapProc';
        
    case 'offset_map'
        procName = 'transientMapProc';
        
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

    case 'drnl'
        procName = 'drnlProc';
        
    case 'pitch'
        procName = 'pitchProc';
        
    case 'gabor'
        procName = 'gaborProc';
        
    otherwise
        procName = '';
        warning('Signal named %s is invalid or not implemented yet.',signal)
        
end