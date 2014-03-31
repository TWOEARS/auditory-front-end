function [CUE,SET] = calcAverageDeviation(SIGNAL,CUE)
%calcILD   Calculate average deviation within frames.
%
%USAGE
%   [CUE,SET] = calcAverageDeviation(SIGNAL,CUE)
%
%INPUT ARGUMENTS
%      SIGNAL : signal structure
%         CUE : cue structure initialized by init_WP2
% 
%OUTPUT ARGUMENTS
%         CUE : updated cue structure
%         SET : updated cue settings (e.g., filter states)

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/27
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% GET INPUT DATA
% 
% 
% Input signal and sampling frequency
data = SIGNAL.data;
fsHz = SIGNAL.fsHz;


%% GET CUE-RELATED SETINGS 
% 
% 
% Copy settings
SET = CUE.set;


%% DOWNMIX
% 
% 
if ~SET.bBinaural
    % Monoaural signal
    data = mean(data, 3);
end


%% INITIALIZE FRAME-BASED PROCESSING
% 
% 
% Compute framing parameters
wSize = 2 * round(SET.wSizeSec * fsHz / 2);
hSize = 2 * round(SET.hSizeSec * fsHz / 2);
win   = window(SET.winType,wSize);

% Determine size of input
[nSamples,nFilter,nChannels] = size(data);

% Compute number of frames
nFrames = max(floor((nSamples-(wSize-hSize))/hSize),1);


%% COMPUTE AVERAGE DEVIATION
% 
% 
% Allocate memory
avd = zeros(nFilter,nFrames,nChannels);

% Loop over number of auditory filters
for ii = 1 : nFilter
    
    % Loop over number of channels
    for jj = 1 : nChannels
        
        % Framing
        frames = frameData(data(:,ii,jj),wSize,hSize,win,false);
                
        % Calculate average deviation
        avd(ii,:,jj) = calcAvgDev(frames);
    end
end


%% UPDATE CUE STRUCTURE
% 
% 
% Copy cue
CUE.data = avd;


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