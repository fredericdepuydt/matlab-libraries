%   function [y, t, info, ind_over, ind_under, frames] = wfm2read(filename, datapoints, step, startind)
%  
%   loads YT-waveform data from *.wfm file saved by Tektronix TDS5000/B, TDS6000/B/C,
%   or TDS/CSA7000/B, MSO70000/C, DSA70000/B/C DPO70000/B/C DPO7000/ MSO/DPO5000
%   instrument families into the variables y (y data) and t (time
%   data). The structure "info" contains information about units and
%   digitizing resolution of the y data. The matrices ind_over and ind_under
%   contain the indices of overranged data points outside the upper / lower
%   limit of the TDS AD converter.
%   If the file contains fast frames data, the data of the first frame is
%   stored as usual and of all frames it is stored in the optional
%   output struct "frames":
%   frames.frame#.y=(y-data of #-th frame, including the first frame again)
%   frames.frame#.t
%   frames.frame#.info (contains only frame-specific fields of the info structure for frame number #)
%   frames.frame#.ind_over
%   frames.frame#.ind_under
%  
%   optional input arguments:
%   datapoints, step,startind: read data points startind:step:datapoints
%   from the wvf file. if datapoints is omitted, all data are read, if step
%   is omitted, step=1. If startind omitted, startind=1
% 
%
