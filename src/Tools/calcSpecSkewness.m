function out = calcSpecSkewness(spec)
%calcSpecSkewness   Compute the spectral skewness.
%   
%USAGE
%      out = calcSpecSkewness(spec)
%
%INPUT ARGUMENTS
%     spec : spectrum [nFrames x nFreq]
% 
%OUTPUT ARGUMENTS
%      out : spectral skewness [nFrames x 1]


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
if nargin < 1 || nargin > 1
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Determine size of input data
nFreqReal = size(spec,2);


%% **************************  COMPUTE FEATURE  ***************************
% 
% 
% Prevent division by zero
epsilon = 1E-15;

% Derive mean and standard deviation
mu_x  = mean(abs(spec),   2);
std_x = std(abs(spec), 0, 2);

% Remove mean
X = spec - repmat(mu_x, [1 nFreqReal]);

% Compute skewness
out = mean((X.^3)./(repmat(std_x + epsilon, [1 nFreqReal]).^3),2);


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