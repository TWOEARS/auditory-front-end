function [SIGNAL,SET] = process_InnerHairCell(INPUT,SIGNAL)
%process_InnerHairCell   Perform inner hair cell processing.
%
%USAGE
%   [SIGNAL,SET] = process_InnerHairCell(INPUT,SIGNAL)
%
%INPUT PARAMETERS
%          INPUT : gammatone domain signal structure 
%         SIGNAL : signal structure initialized by init_WP2
% 
%OUTPUT PARAMETERS
%         SIGNAL : modified signal structure
%            SET : updated signal settings (e.g., filter states)

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May, Nicolas Le Goff © 2013,2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%              nlg@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/31
%   v.0.2   2014/02/24 added SET to output parameters 
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
data = INPUT.data;
fsHz = INPUT.fsHz;


%% GET SIGNAL-RELATED SETINGS 
% 
% 
% Copy settings
SET = SIGNAL.set;


%% RESAMPLING
% 
% 
% Resample input signal, is required
if fsHz ~= SIGNAL.fsHz 
    data = resampleData(data,SIGNAL.fsHz,fsHz);
    fsHz = SIGNAL.fsHz;
end


%% EXTRACT INNER HAIR CELL ENVELOPE
%
% 
% Hair cell processing
data(:,:,1) = ihcenvelope(data(:,:,1),fsHz,SET.ihcMethod);
data(:,:,2) = ihcenvelope(data(:,:,2),fsHz,SET.ihcMethod);


%% UPDATE SIGNAL STRUCTURE
% 
% 
% Copy signal
SIGNAL.data = data;

