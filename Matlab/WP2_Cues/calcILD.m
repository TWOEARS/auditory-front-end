function [ild,SET] = calcILD(signal,SET)
%calcILD   Calculate interaural level differences (ILDs). 
%   Negative ILDs are associated with sound sources positioned at the
%   left-hand side and positive ILDs with sources at the right-hand side.  
%
%USAGE
%         ild = calcILD(periphery,P)
%
%INPUT ARGUMENTS
%   periphery : auditory signal
%           P : parameter structure
%
%OUTPUT ARGUMENTS
%         ild : Interaural Level Difference in decibel [nFilter x nFrames]

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/22
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% INITIATE FRAMING
% 
% 
% Determine size of input
[nSamples,nFilter,nChannels] = size(signal); %#ok

% Compute number of frames
nFrames = max(floor((nSamples-(SET.wSize-SET.hSize))/SET.hSize),1);


%% COMPUTE ILD
% 
% 
% Allocate memory
ild = zeros(nFilter,nFrames);

% Loop over number of auditory filters
for ii = 1 : nFilter
    
    % Framing
    frames_L = frameData(signal(:,ii,1),SET.wSize,SET.hSize,SET.win,false);
    frames_R = frameData(signal(:,ii,2),SET.wSize,SET.hSize,SET.win,false);
    
    % Compute energy
    energyL = mean(power(frames_L,2),1);
    energyR = mean(power(frames_R,2),1);
    
    % Calculate interaural level difference
    ild(ii,:) = 10 * (log10(energyR + eps) - log10(energyL + eps));
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