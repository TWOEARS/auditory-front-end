function [peakIdx,I,J] = findLocalPeaks(data,method,bRejectBoundaries)
%findLocalPeaks   Find local peaks or maxima in 2D data.
%
%USAGE
%          peakIdx    = findLocalPeaks(data)
%         [peakIdx,I] = findLocalPeaks(data,method,bRejectBoundaries)
%
%INPUT PARAMETERS
%                data : input data [nSamples x nChannels]
%              method : string defining peak detection method
%                       'peaks' - find all local peaks
%                       'max'   - find maximum per channel
%   bRejectBoundaries : remove start and endpoints from list of peak
%                       positions  
% 
%OUTPUT PARAMETERS
%             peakIdx : single index peak positions
%                   I : row subscripts of peak positions
%                   J : column subscripts of peak positions

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2013
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/21
%   v.0.2   2014/03/05 added 2D peak detection
%   v.0.3   2014/03/06 added column subscripts to output parameters
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
if nargin < 3 || isempty(bRejectBoundaries); bRejectBoundaries = false;   end
if nargin < 2 || isempty(method);            method            = 'peaks'; end

% Determine input size
[nSamples,nChannels,dim] = size(data);

% Check if input is of not larger than 2D
if dim > 1
    error('Only 2D matrices are supported.')
end


%% FIND PEAK POSITIONS
% 
% 
% Select method
switch lower(method)
    case 'peaks'
  
        % Data point must be larger than the two neighboring values
        minDist = 1;
        
        % Overall window size (odd)
        wSize = minDist*2+1;
        
        % Maximum filtering
        dataM = ordfilt2(data,wSize,ones(wSize,1),'symmetric');
        
        % Find local peaks
        [I, J] = find(dataM == data);
        
        % Transform row and column indices to single index peak positions
        peakIdx = sub2ind([nSamples nChannels],I,J);
        
        % Remove peak candidates
        bRemove = false(size(peakIdx));
        
        % Detect endpoints
        bStart = I == 1;
        bEnd   = I == nSamples;
        bPeaks = ~bStart & ~bEnd;
        
        % Handle start and endpoints
        if bRejectBoundaries
            % Remove boundaries
            bRemove(bStart) = true;
            bRemove(bEnd)   = true;
        else
            % Allow start and endpoints to be local peaks
            bRemove(bStart) = bRemove(bStart) | data(peakIdx(bStart))<= data(peakIdx(bStart)+1);
            bRemove(bEnd)   = bRemove(bEnd)   | data(peakIdx(bEnd))  <= data(peakIdx(bEnd)-1);
        end
        
        % Check if detected peaks are true peaks
        bRemove(bPeaks) = bRemove(bPeaks) | data(peakIdx(bPeaks)) <= data(peakIdx(bPeaks)-1);
        bRemove(bPeaks) = bRemove(bPeaks) | data(peakIdx(bPeaks)) <= data(peakIdx(bPeaks)+1);
        
        % Remove peak candidates
        peakIdx(bRemove) = [];
        I(bRemove)       = [];
        J(bRemove)       = [];

    case 'max'
        % Detect maximum per channel
        if bRejectBoundaries
            I = 1 + argmax(data(2:end-1,:,:),1).';
        else
            I = argmax(data,1).';
        end
        
        % Column index peak positions
        J = (1:nChannels).';
        
        % Single index peak positions
        peakIdx = I + (J-1) * nSamples;
        
    otherwise
        error('Method ''%s'' is not supported!',lower(method))
end