% This script adds the necessary paths for the Two!Ears Auditory Cues
% extraction framework and set up the needed pathes. Make sure to
% clear yourself the Matlab workspace, if that is necessary.

path = fileparts(mfilename('fullpath'));
addpath(genpath(path),genpath([path filesep '..' filesep 'test']))
clear path
