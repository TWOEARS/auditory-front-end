function data = resampleData(data,fsHz,fsHzNew)
%resampleData   Resample N-dimensional data.
%
%USAGE
%   [SIGNAL,SET] = resampleData(INPUT,SIGNAL)
%
%INPUT PARAMETERS
%           data : N-dimensional data
%           fsHz : sampling frequency in Hertz of input data
%        fsHzNew : new sampling frequency in Hertz
% 
%OUTPUT PARAMETERS
%           data : resampled input data

%   Developed with Matlab 8.3.0.532 (R2014a). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/04/04
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% PERFORM RESAMPLING
% 
% 
% Determine input size
dim = size(data);

% Re-organize N-dimensional data into 2D matrix
data = reshape(data,[dim(1) prod(dim(2:end))]);

% Perform resampling colum-wise 
data = resample(data,fsHzNew,fsHz);

% Re-organize data
data = reshape(data,[size(data,1) dim(2:end)]);
     