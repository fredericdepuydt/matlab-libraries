%  ISFREAD  Read a Tektronix ISF file.
%     DATA = ISFREAD(FILENAME) reads the Tektronix ISF file given by FILENAME
%     and returns a structure containg the data and the header.
%  
%     DATA = ISFREAD(DIRECTORY) reads all files with the extension '.ISF' or
%     '.isf' in the specified directory and returns a structure array
%     containing the data and the headers. If n files are read, the structure
%     array will have size 1xn.
%  
%     DATA = ISFREAD(PATTERN) reads the files matched by the specified
%     PATTERN. PATTERN can be a wildcard, such as '*.ISF'. Itreturns a
%     structure array containing the data and the headers. There is one
%     element for each file read. If n files are read, the structure array
%     will have size 1xn.
%  
%   ISF is the name of an internal data format used by Tektronix
%   oscilloscopes. The files consist of a short text header followed by
%   binary data.
%  
%   This function was written to read data saved by a model TDS 360
%   oscilloscope, but is likely to work with other models that use the ISF
%   format. It was tested by saving the same waveform on the oscilloscope
%   in both comma-separated values (CSV) format and ISF, then comparing CSV
%   data to that returned by ISFREAD.
%  
%   The DATA structure contains the following fields:
%      filename
%      datetime
%      header
%      x
%      y
%  
%   The field datetime is file's modification date and time. This date and
%   time may originate from the oscilloscope's internal clock, or from a
%   computer subsequently used to copy the files. The value will be
%   locale-dependent.
%  
%   EXAMPLES:
%   1. data = isfread('TEK00000.ISF');
%      plot(data.x,data.y);
%  
%   3. data = isfread('*.ISF');
%      plot([data.x], [data.y]);
%      legend([data.datetime]);
%  
%   This function is based on <a
%   href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/6247')">isfread</a> by John Lipp.
%  
%   See also
%     Programmer Manual for Tektronix TDS 340A, TDS 360 and TDS 380 Digital
%     Real-Time Oscilloscopes (070-9442-02).
%  
%   Iain Robinson, School of Geosciences, University of Edinburgh.
%   Last updated: 2012-09-11
% 
%
