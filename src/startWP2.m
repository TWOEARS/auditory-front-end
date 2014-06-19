clear all
close all
clc

% This script add the necessary paths for the WP2 botton-up feature
% extraction framework and set up the wp2 repository as the current
% directory

path = fileparts(mfilename('fullpath'));
addpath(genpath(path),genpath([path filesep '..' filesep 'test']))
cd([path filesep '..'])