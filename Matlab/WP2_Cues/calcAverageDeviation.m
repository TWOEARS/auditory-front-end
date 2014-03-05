function [avd,SET] = calcAverageDeviation(signal,SET)
%calcILD   Calculate average deviation within frames.
%
%USAGE
%   [avd,SET] = calcAverageDeviation(signal,SET)
%
%INPUT ARGUMENTS
%    signals : auditory signal
%        SET : parameter structure
%
%OUTPUT ARGUMENTS
%        avg : average deviation [nFilter x nFrames]

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


%% DOWNMIX
% 
% 
if ~SET.bBinaural
    % Monoaural signal
    signal = mean(signal, 3);
end


%% INITIATE FRAMING
% 
% 
% Determine size of input
[nSamples,nFilter,nChannels] = size(signal); 

% Compute number of frames
nFrames = max(floor((nSamples-(SET.wSize-SET.hSize))/SET.hSize),1);


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
        frames = frameData(signal(:,ii,jj),SET.wSize,SET.hSize,SET.win,false);
                
        % Calculate average deviation
        avd(ii,:,jj) = calcAvgDev(frames);
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