clear;
clc;
cd(fullfile(matlabroot,'toolbox','local'));
getdirectories;
addpath(genpath(librarydirectory));
cd(librarydirectory);
savepath;
%copyfile([funcdirectory '\startup.bak.m'],[mfilename('fullpath') '.m']);
clear librarydirectory;

global rootdirectory;
cd(rootdirectory);