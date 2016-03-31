% This script adds the necessary paths for the Two!Ears Auditory Front-End
% extraction framework and set up the needed pathes. Make sure to clear
% yourself the Matlab workspace, if that is necessary.

basePath = fileparts(mfilename('fullpath'));
addPathsIfNotIncluded( ...
    [ strsplit( genpath(fullfile(basePath, 'src')), pathsep ) ...
      strsplit( genpath(fullfile(basePath, 'test')), pathsep )] ...
      );

clear basePath
