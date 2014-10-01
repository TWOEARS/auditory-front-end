function out = calcSpecVariation(spec)
%calcSpecVariation   Compute the spectral variation between frames.
%   
%USAGE
%      out = calcSpecVariation(spec)
%
%INPUT ARGUMENTS
%     spec : spectrum [nFrames x nFreq]
% 
%OUTPUT ARGUMENTS
%      out : spectral variation [nFrames x 1]
% 
%REFERENCES
%   [1] G. Peeters, B. L. Giordano, P. Susini, N. Misdariis and S. McAdams
%       (2011). "The Timbre Toolbox: extracting audio descriptors from
%       musical signals.", The Journal of the Acoustical Society of
%       America, vol. 130, nr. 5, pp. 2902-2916.    

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
% "Last" frame
pSpec_past = spec(1,:);

pSpec_tm    = spec;
pSpec_tm_m1 = [pSpec_past; spec(1:end-1,:)];

% Cross-product
spec_xprod = sum(pSpec_tm .* pSpec_tm_m1,2);
% Auto-product
spec_aprod = sqrt(sum(pSpec_tm.^2,2)) .* sqrt(sum(pSpec_tm_m1.^2,2));

% 1 - Noralized cross-correlation 
out = 1 - (spec_xprod ./ spec_aprod);

% Avoid NaNs due to silent frames
out(spec_aprod == 0) = 0;


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