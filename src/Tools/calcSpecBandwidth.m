function out = calcSpecBandwidth(spec,fHz)
%calcSpecBandwidth   Compute the spectral bandwidth in Hertz.
%   
%USAGE
%      out = calcSpecBandwidth(spec,fHz)
%
%INPUT ARGUMENTS
%     spec : spectrum [nFrames x nFreq]
%      fHz : frequency vector in Hertz [nFreq x 1]
% 
%OUTPUT ARGUMENTS
%      out : spectral bandwidth in Hertz [nFrames x 1]
% 
%REFERENCES
%   [1] L. Dongge and I. K. Sethi and N. Dimitrova and T. McGee (2001).
%       "Classification of general audio data for content-based retrieval",
%       Pattern Recognition Letters, vol. 22, issue 4, pp. 533-544 


%   Developed with Matlab 8.1.0.604 (R2013a). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2013
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2013/09/06
%   ***********************************************************************


%% ***********************  CHECK INPUT ARGUMENTS  ************************
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Determine size of input data
[nFrames, nFreqReal] = size(spec);

% Check size of frequency vector
if nFreqReal ~= numel(fHz)
    error('Frequency vector does not match size of spectrum!')
else
    % Ensure fHz is a row vector
    fHz = fHz(:).';
end


%% **************************  COMPUTE FEATURE  ***************************
% 
% 
% Prevent division by zero
epsilon = 1E-15;

% Compute spectral centroid
sc = calcSpecCentroid(spec,fHz);

% Nominator
nom = (repmat(fHz,[nFrames 1]) - repmat(sc,[1 nFreqReal ])).^2 .* spec;

% Spectrum bandwidth
out = sqrt(sum(nom,2)./(sum(spec,2) + epsilon));


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