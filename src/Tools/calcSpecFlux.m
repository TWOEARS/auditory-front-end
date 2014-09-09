function out = calcSpecFlux(spec)
%calcSpecFlux   Compute the spectral difference between succesive frames.
%   
%USAGE
%      out = calcSpecFlux(spec)
%
%INPUT ARGUMENTS
%     spec : spectrum [nFrames x nFreq]
% 
%OUTPUT ARGUMENTS
%      out : spectral flux in dB [nFrames x 1]


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


%% **************************  COMPUTE FEATURE  ***************************
% 
%
% Prevent NaNs after log operation
epsilon = 1E-15;

% Compress power spectrum
pSpec = 10 * log10(spec + epsilon);

% "Last" frame
pSpec_past = pSpec(1,:);

% Compute delta across frames
deltaSpec = diff([pSpec_past; pSpec],1,1);

% 2-Norm of spectrum difference across succesive frames. The mean is used
% to be independent of the spectral resolution (number of frequencies) 
out = sqrt(mean(power(deltaSpec,2),2));


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