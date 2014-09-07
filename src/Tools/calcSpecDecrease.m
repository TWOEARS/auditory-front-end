function out = calcSpecDecrease(spec)
%calcSpecDecrease   Compute the spectral decrease.
%   
%USAGE
%      out = calcSpecDecrease(spec)
%
%INPUT ARGUMENTS
%     spec : spectrum [nFrames x nFreq]
% 
%OUTPUT ARGUMENTS
%      out : spectral decrease [nFrames x 1]
% 
%REFERENCES
%   [1] G. Peeters (2004). "A large set of audio features for sound
%       description (similarity and classification) in the CUIDADO
%       project", Paris : Ircam, Analysis/Synthesis Team. 

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
% Index vector
k    = (0:nFreqReal-1)';
k(1) = 1;
kinv = 1./k;

% Compute spectral decrease
out = ((spec-repmat(spec(:,1),[1 nFreqReal]))*kinv)./(sum(spec(:,2:end),2));

% Avoid NaNs for silent frames
out(sum(spec(:,2:end),2) == 0) = 0;


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