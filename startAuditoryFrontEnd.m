% This script adds the necessary paths for the Two!Ears Auditory Front-End
% extraction framework and set up the needed pathes. Make sure to clear
% yourself the Matlab workspace, if that is necessary.

path = fileparts(mfilename('fullpath'));
addpath(genpath([path filesep 'src'),genpath([path filesep 'test']))
clear path
