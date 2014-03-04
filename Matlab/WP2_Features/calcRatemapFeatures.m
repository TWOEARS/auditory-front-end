function [ratemap,SET] = calcRatemapFeatures(CUE,SET)
% 
%USAGE
%    ratemap = calcRatemapFeatures(CUE,S)
%
%INPUT PARAMETERS
% 
%OUTPUT PARAMETERS
% 

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/23
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
    % Monoaural feature space
    ratemap = mean(CUE.data, 3);
else
    % Binaural feature space
    ratemap = CUE.data;
end


%% COMPRESS RATEMAP REPRESENTATION
% 
% 
% Apply compression
switch lower(SET.compress)
    case 'cuberoot'
        ratemap = ratemap.^0.33;
    case 'log'
        ratemap = log(ratemap);
    otherwise
        error('%s: Compression ''%s'' is not supported.',mfilename,SET.compress);
end


%% PERFORM NORMALIZATION
% 
% 
% Apply feature normalization
for ii = 1 : size(ratemap,3)
    ratemap(:,:,ii) = normalizeData(ratemap(:,:,ii).',SET.normalize).';
end
