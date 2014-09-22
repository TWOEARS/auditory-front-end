function out = calcSpecRolloff(spec,fHz,thresPerc)
%calcSpecRolloff   Calculates the spectral rolloff in Hertz.
%   
%USAGE
%         out = calcSpecRolloff(spec,fHz,thresPerc)
%
%INPUT ARGUMENTS
%        spec : spectrum [nFrames x nFreq]
%         fHz : frequency vector in Hertz [nFreq x 1]
%   thresPerc : energy threshold in percent (default, thresPerc = 0.85)
% 
%OUTPUT ARGUMENTS
%         out : spectral rolloff in Hertz [nFrames x 1]
% 
%REFERENCES
%   [1] G. Tzanetakis and P. Cook (2002). "Musical genre classification of
%       audio signals", IEEE Transactions on Speech and Audio Processing,
%       vol. 10, issue 5, pp. 293-302. 

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
if nargin < 2 || nargin > 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default parameter
if nargin < 3 || isempty(thresPerc); thresPerc = 0.85; end

% Determine size of input data
[nFrames, nFreqReal] = size(spec);

% Check size of frequency vector
if nFreqReal ~= numel(fHz)
    error('Frequency vector does not match size of spectrum!')
else
    % Ensure fHz is a column vector
    fHz = fHz(:);
end

% Check range of threshold parameter
if thresPerc < 0 || thresPerc > 1
    error('Energy threshold must be within [0, 1]')
end


%% **************************  COMPUTE FEATURE  ***************************
% 
% 
% Flag to select interpolation method
bUseInterp = true;

% Allocate memory
out = zeros(nFrames,1);

% Ensure that cumsum(spec) increases monotonically
epsilon = 1E-10;

% Spectral energy across frequencies multiplied by threshold parameter
spec_sum_thres = thresPerc * sum(spec,2);
% Cumulative sum (+ epsilon ensure that cumsum increases monotonically)
spec_cumsum = cumsum(spec + epsilon,2);

% Loop over number of frames
for ii = 1 : nFrames
   
    % Use interpolation
    if bUseInterp
        if spec_sum_thres(ii) > 0
            % Detect spectral roll-off
            out(ii) = interp1(spec_cumsum(ii,:),fHz,spec_sum_thres(ii),'linear','extrap');
        end
    else
        % The feature range of this code is limited to the vector fHz.
        
        % Detect spectral roll-off
        r = find(spec_cumsum(ii,:) > spec_sum_thres(ii),1);
        
        % If roll-off is found ...
        if ~isempty(r)
            % Get frequency bin
            out(ii) = fHz(r(1));
        end
    end
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