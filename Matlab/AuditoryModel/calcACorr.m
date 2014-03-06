function [acorr,lags] = calcACorr(sig,maxLags,scale)
%calcACorr   FFT-based cross-correlation function.
%
%USAGE
%	       ACORR = calcACorr(SIG)
%	[ACORR,LAGS] = calcACorr(SIG,MAXLAGS,SCALE)
%
%INPUT ARGUMENTS
%       SIG : input signal, either vector or matrix of dimension
%             [nSamples x nChannels]
%   MAXLAGS : the correlation sequenze is computed over the lag range
%             -MAXLAGS:MAXLAGS 
%             (default, MAXLAGS = size(SIG,1)-1
%     SCALE : string specifying normalization 
%             'biased'   - scale ACORR by 1/nSamples
%             'unbiased' - scale ACORR by 1/(nSamples-abs(lags))
%             'coeff'    - scale ACORR by the autocorrelation at lag zero
%             'none'     - no scaling
%             (default, scale = 'none')
%
%OUTPUT ARGUMENTS
%     ACORR : auto-correlation function of SIG [2*MAXLAGS+1 x nChannels]
%      LAGS : time lags of auto-correlation function [-MAXLAG:MAXLAG x 1]


%   Developed with Matlab 7.4.0.287 (R2007a). Please send bug reports to:
%   
%   Author  :  Tobias May � 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk%
% 
%   History :   
%   v.0.1   2014/03/05
%   ***********************************************************************


%% ***********************  CHECK INPUT ARGUMENTS  ************************
% 
% 
% Set default values
if nargin < 3 || isempty(scale); scale = 'none'; end

% FFT approach for matrices...
[blockSize,nChannels,check] = size(sig);

% Check dimensionaly of input signals
if any(check > 1)
    error('Require either vector or matrix as input!');
end

% Work along non-singleton dimension
if blockSize == 1 
    % Transpose data
    sig = transpose(sig);
    
    % Swap channel to blockSize
    blockSize = nChannels;
end

% Determine maximum number of samples ...
M = blockSize;

% Set default number of lags if necessary...
if nargin < 2 || isempty(maxLags);  maxLags = M - 1; end


%% **************************  COMPUTE SPECTRA  ***************************
% 
% 
% Transform both input signals
X = fft(sig,2^nextpow2(2*M-1));

% Compute cross-power spectrum
XY = abs(X).^2;


%% ************************  BACK TO TIME DOMAIN  *************************
% 
% 
% Inverse FFT
c = real(ifft(XY));   

% Define lags 
lags = (-maxLags:maxLags).';

% Keep only the lags we want and move negative lags in front 
if maxLags >= M,
    % Pad with zeros
    padZeros = zeros(maxLags-M+1,nChannels);
	c        = [padZeros; c(end-M+2:end,:);c(1:M,:); padZeros];
else
	c = [c(end-maxLags+1:end,:);c(1:maxLags+1,:)];
end


%% ***************************  NORMALIZATION  ****************************
% 
% 
% Normalization
switch lower(scale)
    case 'none'
        acorr = c;
    case 'biased'
        acorr = c / M;
    case 'unbiased'
        scale = M-abs(lags'); scale(scale<=0)=1;
        acorr = c./repmat(scale(:),[1 nChannels1]);
    case 'coeff'
        % Normalization by autocorrelation at lag zero
        acorr = c ./ repmat(c(maxLags+1,:),[length(lags) 1]);
    otherwise
        error(['Normalization method ''',lower(scale),...
               ''' is not supported.'])
end


%   ***********************************************************************
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%   ***********************************************************************