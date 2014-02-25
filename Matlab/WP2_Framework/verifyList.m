function msg = verifyList(selected,fullList)

% Update feature list to consider proper order of processing

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

% Check if all features are supported
bSupported = selectCells(selected,fullList);

msg = [];

if any(~bSupported)
   for ii = find(~bSupported); 
       msg = [msg, '''',selected{ii},'''',' ']; %#ok
   end
end
