function adev = calcAvgDev(input)
%calcAvgDev   Calculates the average deviation of a signal. 
%
%USAGE
%    adev = calcAvgDev(input)
%   
%INPUT ARGUMENTS
%   input : input data [nSamples x nChannels]
% 
%OUTPUT ARGUMENTS
%    adev : average deviation across nSamples [1 x nChannels]

%   Developed with Matlab 7.10.0.499 (R2010a). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2011 
%              University of Oldenburg and TU/e Eindhoven   
%              tobias.may@uni-oldenburg.de   t.may@tue.nl
%
%   History :
%   v.0.1   2011/12/12
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 1
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% MEX-BASED PROCESSING
% 
% 
% Compute average deviation (MEX processing)
adev = calcAvgDevMEX(input);


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