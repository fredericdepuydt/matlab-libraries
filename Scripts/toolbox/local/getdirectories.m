%% PREFIX PROJECTS DIRECTORY
prefix{1}='%LIB:Projects%';
prefix{2}='D:\Users\Frederic Depuydt\Google Drive\Projects';
prefix{3}='E:\Users\Frederic Depuydt\Google Drive\Projects';
prefix{4}='E:\Users\Frederic\Projects';

%% MATLAB PROJECTS LIBRARY DIRECTORY
librarydirectory = find_dir(prefix, '\MATLAB\00.User-defined Functions');

%% MATLAB PROJECTS ROOT DIRECTORY
global rootdirectory
rootdirectory = find_dir(prefix, '\MATLAB');

%% CLEANING UP
clear prefix;

