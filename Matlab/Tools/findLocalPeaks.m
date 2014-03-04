function [peakIdx,I] = findLocalPeaks(data,method,minDist)
%findLocalPeaks   Find local peaks.
%
%USAGE
%   [peakIdx,I] = findLocalPeaks(data,method,minDist)
%
%INPUT PARAMETERS
%          data : input data [nSamples x nChannels]
%        method : string defining peak detection method
%                 'peaks' - find all local peaks
%                 'max'   - find maximum per channel
% 
%OUTPUT PARAMETERS
%       peakIdx : single index peak positions
%             I : row subscripts of peak positions

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2013
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/21
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin < 1 || nargin > 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default parameter
if nargin < 3 || isempty(minDist); minDist = 1;       end
if nargin < 2 || isempty(method);  method  = 'peaks'; end

% Determine input size
[nSamples,nChannels] = size(data);


%% FIND PEAK POSITIONS
% 
% 
% Select method
switch lower(method)
    case 'peaks'
        
        peakIdx = []; I = [];
        
        % Loop over number of channels
        for ii = 1 : nChannels
            pIdx    = findpeaks(data(:,ii));
            peakIdx = [peakIdx; pIdx(:) + (ii-1) * nSamples];
            I       = [I; pIdx(:)];
        end
        
%         % Overall window size (odd)
%         wSize = minDist*2+1;
%         
%         % Maximum filtering
%         dataM = ordfilt2(data,wSize,ones(wSize,1),'symmetric');
%         
%         % Find local peaks
%         [I, J] = find(dataM == data);
%         
%         % Transform peak positions to indices
%         peakIdx = sub2ind([nSamples nChannels],I,J);
        
    case 'max'
        % Detect maximum per channel
        I = argmax(data,1).';
        
        % Row subscripts of peak positions
        peakIdx = I + (0:nChannels-1).'*nSamples;
        
    otherwise
        error('Method is not supported!')
end