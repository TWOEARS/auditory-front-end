function [data,SET] = process_InnerHairCell(data,SET)
%
%USAGE
%   [signal,STATES] = process_InnerHairCell(signal,STATES)
%
%INPUT PARAMETERS
%       signal : gammatone signals [nSamples x nFilters x 2]
%       STATES : settings initialized by init_WP2
% 
%OUTPUT PARAMETERS
%       signal : Peripheral internal representations [nSamples x nFilter x 2]

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May, Nicolas Le Goff © 2013,2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%              nlg@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/31
%   v.0.2   2014/02/24 added STATES to output (for block-based processing)
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% EXTRACT INNER HAIR CELL ENVELOPE
%
% 
% Hair cell processing
data(:,:,1) = ihcenvelope(data(:,:,1),SET.fsHz,SET.ihcMethod);
data(:,:,2) = ihcenvelope(data(:,:,2),SET.fsHz,SET.ihcMethod);

