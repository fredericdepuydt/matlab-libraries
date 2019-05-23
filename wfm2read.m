function [y, t, info, ind_over, ind_under, frames] = wfm2read(filename, datapoints, step, startind)
% function [y, t, info, ind_over, ind_under, frames] = wfm2read(filename, datapoints, step, startind)
%
% loads YT-waveform data from *.wfm file saved by Tektronix TDS5000/B, TDS6000/B/C,
% or TDS/CSA7000/B, MSO70000/C, DSA70000/B/C DPO70000/B/C DPO7000/ MSO/DPO5000
% instrument families into the variables y (y data) and t (time
% data). The structure "info" contains information about units and
% digitizing resolution of the y data. The matrices ind_over and ind_under
% contain the indices of overranged data points outside the upper / lower
% limit of the TDS AD converter.
% If the file contains fast frames data, the data of the first frame is
% stored as usual and of all frames it is stored in the optional
% output struct "frames":
% frames.frame#.y=(y-data of #-th frame, including the first frame again)
% frames.frame#.t
% frames.frame#.info (contains only frame-specific fields of the info structure for frame number #)
% frames.frame#.ind_over
% frames.frame#.ind_under
%
% optional input arguments:
% datapoints, step,startind: read data points startind:step:datapoints
% from the wvf file. if datapoints is omitted, all data are read, if step
% is omitted, step=1. If startind omitted, startind=1

%
% Reading of *.wfm files written by other than the above Oscilloscopes may
% result in errors, since the file format seems not to be downward compatible.
% Other projects exist for the older format, e.g. wfmread.m by Daniel Dolan.
%
% Author:
% Erik Benkler
% Physikalisch-Technische Bundesanstalt
% Section 4.53: Optical Femtosecond Metrology
% Bundesallee 100
% D-38116 Braunschweig
% Germany
% Erik.Benkler a t ptb.de
%
% The implementation is based on Tektronix Article 077-0220-01
% (December 07, 2010): "Performance Oscilloscope Reference Waveform File Format"
% which can be found at:
% http://www2.tek.com/cmswpt/madetails.lotr?ct=MA&cs=mpm&ci=17905&lc=EN
% or by searching for 077022001 on the TEKTRONIX website (the last two
% digits seem to define the revision of the document, so you may search for
% 077922002, 077922003, ... to find newer revisions in future.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% current state of the project and change history:
%
% Version 2.0, 22.03.2011
% (a)    added warning IDs for all warnings to render them switchable
% (b)    changed behaviour of the "datapoints" input parameter, which now
%        defines the number of data points to be returned by wfm2read.
%        Added a warning when "datapoints" is too large such that one would
%        need more data points in the file / frame.
%
% Version 1.9, December 26, 2010 (re-submitted to FileExchange)
% (a)   implemented Fast frames
% (b)   added wfm2readframe for reading single frame
%       in a fast frames measurement
% (c)   Added optional input argument startind, for starting reading at
%       this datapoint within each frame
%
% Version 1.8, April 30, 2009 (re-submitted to FileExchange)
% (a)   improved file name checking
%
% Version 1.7, January 26, 2009 (re-submitted to FileExchange):
% (a)   improved performance when using the step argument by preallocating
%       the array
% (b)   moved all "unused" read variables to info structure (produces less
%       m-lint messages)
%
% Version 1.6, July 23, 2008 (re-submitted to FileExchange):
% (a)   Fixed the bug related to default char set on some Linux systems
%       pointed out by Markus Kuhn
% (b)   Added compatibility with WFM003 format as suggested by Will Fox.
%       (the comment in footnote 6 of the SDK on pixmap size has not been
%       regarded).
%       For a description of the new file format, download and unzip
%       http://www.tek.com/products/oscilloscopes/openchoice/SDK_CD_2.0_122
%       72006.zip and look for the file 001137803.pdf in the subdirectory
%       bin/Articles/
%
% Version 1.5, December 11, 2005:
% (a)   added "step" input argument for reduced data reading.
%
% Version 1.4, November 11, 2005:
% (a)   changed to read unit string until NULL string only.
%
% Version 1.3, October 31, 2005 (submitted to FileExchange):
% (a)   Added handling of overranged values. Added two output variables
%       ind_over and ind_under for this purpose.
%
% Version 1.2, July 07, 2005:
% (a)   Added optional second input parameter to limit the number of data
%       points to be read.
%
% Version 1.1, April 12, 2005:
% (a)   Removed the bug that the byte order verification (big-endian vs. little-endian)
%       was disregarded.
% (b)   close file at the end.
% (c)   Checked functionality with YT-waveform measured with TDS6804B scope.
%
% Version 1.0, December 20, 2004
%
% Already done:
% 1) All file fields listed in the SDK article are assigned to variables named like in the SDK article
% 2) Only reading of YT waveform is implemented. It is assumed that the waveform is
% a simple YT waveform. This is not checked and may result in errors when waveform is other than YT.
% 3) Optional WFM#002 format is implemented (footnote 6 in SDK article)
% 4)Checked functionality with YT-waveform measured with TDS5104B scope
%
% Yet to be done:
% 1) reading of XY-wavefroms etc.
% 2) handle interpolated data
% 3) error checking, e.g. after each file operation, or checking if data is YT waveform should be improved
% 4) only some important header information is output at this stage
% 5) file checksum not yet implemented
% 6) how to handle old format wfm files? Downward compatibility...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% beginning of code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%checking of file name etc.
if nargin==0
    filename='';
end
if nargin<3
    step=1;
end

if nargin<4
    startind=1;
end

if isempty(filename)
    [fname,pname]=uigetfile({'*.wfm', 'Tektronix Waveform Files (*.wfm)'},'Choose Tektronix WFM file');
    filename=[pname fname];
    if fname==0 %user pressed Cancel
        y=[];
        t=[];
        ind_over=[];
        ind_under=[];
        info=[];
        frames=[];
        return
    end
end

[pname,fname] = fileparts(filename);
if isempty(pname)
    pname='.';
end

if exist([pname,'\', fname,'.wfm'],'file')~=2
    error(['Invalid file name: ' filename]);
end

filename=[pname,'\',fname,'.wfm'];

[fid,message]=fopen(filename);

if fid==-1
    error(message);
end

if step<1 || (round(step)~=step)
    step=1; 
    warning('WFM2read:stepPosint',['"step" input parameter must be a positive integer.\nSetting step=1.']);
end
if startind<1 || (round(startind)~=startind)
    startind=1; 
    warning('WFM2read:startindPosint',['"startind" input parameter must be a positive integer.\nSetting startind=1.']);
end


%read the waveform static file info
info.byte_order_verification = dec2hex(fread(fid,1,'uint16'),4);
if strcmp(info.byte_order_verification, '0F0F')
    byteorder='l'; % little-endian byte order
else
    byteorder='b'; % big-endian byte order
end
info.versioning_number = char(fread(fid,8,'*uint8',byteorder)');

%There's a misprinting in the SDK article, the ":" at the beginning of version number string is missing.
wfm_version = sscanf(info.versioning_number,':WFM#%3d');
if (wfm_version > 3)
    warning('WFM2read:HigherVersionNumber','wfm2read has only been tested with WFM file versions <= 3');
end

info.num_digits_in_byte_count = fread(fid,1,'*uint8',byteorder);
info.num_bytes_to_EOF = fread(fid,1,'*int32',byteorder);
info.num_bytes_per_point = fread(fid,1,'uint8',byteorder); %do not convert to same type, since required as double later
info.byte_offset_to_beginning_of_curve_buffer = fread(fid,1,'*uint32',byteorder);
info.horizontal_zoom_scale_factor = fread(fid,1,'*int32',byteorder);
info.horizontal_zoom_position = fread(fid,1,'*float32',byteorder);
info.vertical_zoom_scale_factor = fread(fid,1,'*double',byteorder);
info.vertical_zoom_position = fread(fid,1,'*float32',byteorder);
dummy=fread(fid,32,'*uint8',byteorder);
info.waveform_label = char(dummy(1:find(dummy==0)));         %read units until NULL string (suggested by Tom Gaudette)
info.N = fread(fid,1,'*uint32',byteorder);
info.size_of_waveform_header = fread(fid,1,'*uint16',byteorder);

%read waveform header
info.setType = fread(fid,4,'*int8',byteorder);
info.wfmCnt = fread(fid,1,'*uint32',byteorder);
fread(fid,24,'uint8',byteorder); %skip bytes 86 to 109 (not for use)
info.wfm_update_spec_count = fread(fid,1,'*uint32',byteorder);
info.imp_dim_ref_count = fread(fid,1,'*uint32',byteorder);
info.exp_dim_ref_count = fread(fid,1,'*uint32',byteorder);
info.data_type = fread(fid,4,'*int8',byteorder);
fread(fid,16,'uint8',byteorder); %skip bytes 126 to 141 (not for use)
info.curve_ref_count = fread(fid,1,'*uint32',byteorder);
info.num_req_fast_frames = fread(fid,1,'*uint32',byteorder);
info.num_acq_fast_frames = fread(fid,1,'*uint32',byteorder);

%read optional entry in WFM#002 (and higher) file format:

if wfm_version >= 2 % for version number >=2  only
    info.summary_frame_type = fread(fid,1,'*uint16',byteorder);
end

info.pixmap_display_format = fread(fid,4,'*int8',byteorder);
info.pixmap_max_value = fread(fid,1,'uint64',byteorder); %storage in a uint64 variable does not work. Uses only double. Bug in Matlab?

%explicit dimension 1
info.ed1.dim_scale = fread(fid,1,'*double',byteorder);
info.ed1.dim_offset = fread(fid,1,'*double',byteorder);
info.ed1.dim_size = fread(fid,1,'*uint32',byteorder);
dummy=fread(fid,20,'*uint8',byteorder);
info.ed1.units = char(dummy(1:find(dummy==0)));         %read units until NULL string (suggested by Tom Gaudette)
info.ed1.dim_extent_min = fread(fid,1,'*double',byteorder);
info.ed1.dim_extent_max = fread(fid,1,'*double',byteorder);
info.ed1.dim_resolution = fread(fid,1,'*double',byteorder);
info.ed1.dim_ref_point = fread(fid,1,'*double',byteorder);
info.ed1.format = fread(fid,4,'*int8',byteorder);
info.ed1.storage_type = fread(fid,4,'*int8',byteorder);
info.ed1.n_value = fread(fid,1,'*int32',byteorder);
info.ed1.over_range = fread(fid,1,'*int32',byteorder);
info.ed1.under_range = fread(fid,1,'*int32',byteorder);
info.ed1.high_range = fread(fid,1,'*int32',byteorder);
info.ed1.low_range = fread(fid,1,'*int32',byteorder);
info.ed1.user_scale = fread(fid,1,'*double',byteorder);
info.ed1.user_units = char(fread(fid,20,'*uint8',byteorder)');
ed1.user_offset = fread(fid,1,'*double',byteorder);

% changes suggested by WFox
if wfm_version >= 3
    info.ed1.point_density = fread(fid,1,'*double',byteorder);
else
    info.ed1.point_density = fread(fid,1,'*uint32',byteorder);
end
% end changes suggested by WFox

info.ed1.href = fread(fid,1,'*double',byteorder);
info.ed1.trig_delay = fread(fid,1,'*double',byteorder);

%explicit dimension 2
info.ed2.dim_scale = fread(fid,1,'*double',byteorder);
info.ed2.dim_offset = fread(fid,1,'*double',byteorder);
info.ed2.dim_size = fread(fid,1,'*uint32',byteorder);
dummy=fread(fid,20,'*uint8',byteorder);
info.ed2.units = char(dummy(1:find(dummy==0)));         %read units until NULL string (suggested by Tom Gaudette)
info.ed2.dim_extent_min = fread(fid,1,'*double',byteorder);
info.ed2.dim_extent_max = fread(fid,1,'*double',byteorder);
info.ed2.dim_resolution = fread(fid,1,'*double',byteorder);
info.ed2.dim_ref_point = fread(fid,1,'*double',byteorder);
info.ed2.format = fread(fid,4,'*int8',byteorder);
info.ed2.storage_type = fread(fid,4,'*int8',byteorder);
info.ed2.n_value = fread(fid,1,'*int32',byteorder);
info.ed2.over_range = fread(fid,1,'*int32',byteorder);
info.ed2.under_range = fread(fid,1,'*int32',byteorder);
info.ed2.high_range = fread(fid,1,'*int32',byteorder);
info.ed2.low_range = fread(fid,1,'*int32',byteorder);
info.ed2.user_scale = fread(fid,1,'*double',byteorder);
info.ed2.user_units = char(fread(fid,20,'*uint8',byteorder)');
info.ed2.user_offset = fread(fid,1,'*double',byteorder);
if wfm_version >= 3
    info.ed2.point_density = fread(fid,1,'*double',byteorder);
else
    info.ed2.point_density = fread(fid,1,'*uint32',byteorder);
end
info.ed2.href = fread(fid,1,'*double',byteorder);
info.ed2.trig_delay = fread(fid,1,'*double',byteorder);

%implicit dimension 1
info.id1.dim_scale = fread(fid,1,'*double',byteorder);
info.id1.dim_offset = fread(fid,1,'*double',byteorder);
info.id1.dim_size = fread(fid,1,'*uint32',byteorder);
info.id1.units = char(fread(fid,20,'*uint8',byteorder)');
info.id1.dim_extent_min = fread(fid,1,'*double',byteorder);
info.id1.dim_extent_max = fread(fid,1,'*double',byteorder);
info.id1.dim_resolution = fread(fid,1,'*double',byteorder);
info.id1.dim_ref_point = fread(fid,1,'*double',byteorder);
info.id1.spacing = fread(fid,1,'*uint32',byteorder);
info.id1.user_scale = fread(fid,1,'*double',byteorder);
info.id1.user_units = char(fread(fid,20,'*uint8',byteorder)');
info.id1.user_offset = fread(fid,1,'*double',byteorder);
if wfm_version >= 3
    info.id1.point_density = fread(fid,1,'*double',byteorder);
else
    info.id1.point_density = fread(fid,1,'*uint32',byteorder);
end
info.id1.href = fread(fid,1,'*double',byteorder);
info.id1.trig_delay = fread(fid,1,'*double',byteorder);

%implicit dimension 2
info.id2.dim_scale = fread(fid,1,'*double',byteorder);
info.id2.dim_offset = fread(fid,1,'*double',byteorder);
info.id2.dim_size = fread(fid,1,'*uint32',byteorder);
info.id2.units = char(fread(fid,20,'*uint8',byteorder)');
info.id2.dim_extent_min = fread(fid,1,'*double',byteorder);
info.id2.dim_extent_max = fread(fid,1,'*double',byteorder);
info.id2.dim_resolution = fread(fid,1,'*double',byteorder);
info.id2.dim_ref_point = fread(fid,1,'*double',byteorder);
info.id2.spacing = fread(fid,1,'*uint32',byteorder);
info.id2.user_scale = fread(fid,1,'*double',byteorder);
info.id2.user_units = char(fread(fid,20,'*uint8',byteorder)');
info.id2.user_offset = fread(fid,1,'*double',byteorder);
if wfm_version >= 3
    info.id2.point_density = fread(fid,1,'*double',byteorder);
else
    info.id2.point_density = fread(fid,1,'*uint32',byteorder);
end
info.id2.href = fread(fid,1,'*double',byteorder);
info.id2.trig_delay = fread(fid,1,'*double',byteorder);

%time base 1
info.tb1_real_point_spacing = fread(fid,1,'*uint32',byteorder);
info.tb1_sweep = fread(fid,4,'*int8',byteorder);
info.tb1_type_of_base = fread(fid,4,'*int8',byteorder);

%time base 2
info.tb2_real_point_spacing = fread(fid,1,'*uint32',byteorder);
info.tb2_sweep = fread(fid,4,'*int8',byteorder);
info.tb2_type_of_base = fread(fid,4,'*int8',byteorder);

%wfm update specification (first frame only if fast frames)
info.real_point_offset = fread(fid,1,'*uint32',byteorder);
info.tt_offset = fread(fid,1,'*double',byteorder);
info.frac_sec = fread(fid,1,'*double',byteorder);
info.GMT_sec = fread(fid,1,'*int32',byteorder);

%wfm curve information (first frame only if fast frames)
info.state_flags = fread(fid,1,'*uint32',byteorder);
info.type_of_checksum = fread(fid,4,'*int8',byteorder);
info.checksum = fread(fid,1,'*int16',byteorder);
info.precharge_start_offset = fread(fid,1,'*uint32',byteorder);
info.data_start_offset = fread(fid,1,'uint32',byteorder); %do not convert to same type, since required as double later
info.postcharge_start_offset = fread(fid,1,'uint32',byteorder); %do not convert to same type, since required as double later
info.postcharge_stop_offset = fread(fid,1,'*uint32',byteorder);
info.end_of_curve_buffer_offset = fread(fid,1,'*uint32',byteorder);

if nargout==6 %if output of fast frames data is requested
    if info.N>0 %if the file contains fast frame data
        %copy data for first frame to the frame struct (I do this to have all
        %frames in  uniform output structure, although it is clear that this
        %uses more memory than minimally needed, i.e. if not copying the data
        %of the first frame):

        %wfm update specification
        frames.('frame1').('info').real_point_offset=info.real_point_offset;
        frames.frame1.info.tt_offset=info.tt_offset;
        frames.frame1.info.frac_sec=info.frac_sec;
        frames.frame1.info.GMT_sec=info.GMT_sec;

        %wfm curve information
        frames.frame1.info.state_flags=info.state_flags;
        frames.frame1.info.type_of_checksum=info.type_of_checksum;
        frames.frame1.info.checksum=info.checksum;
        frames.frame1.info.precharge_start_offset=info.precharge_start_offset;
        frames.frame1.info.data_start_offset=info.data_start_offset;
        frames.frame1.info.postcharge_start_offset=info.postcharge_start_offset;
        frames.frame1.info.postcharge_stop_offset=info.postcharge_stop_offset;
        frames.frame1.info.end_of_curve_buffer_offset=info.end_of_curve_buffer_offset;

        %read data for the other frames from the file:
        for frm=2:(info.N+1)

            %wfm update specification
            frames.(['frame' num2str(frm)]).('info').real_point_offset = fread(fid,1,'*uint32',byteorder);
            frames.(['frame' num2str(frm)]).info.tt_offset = fread(fid,1,'*double',byteorder);
            frames.(['frame' num2str(frm)]).info.frac_sec = fread(fid,1,'*double',byteorder);
            frames.(['frame' num2str(frm)]).info.GMT_sec = fread(fid,1,'*int32',byteorder);
        end

        for frm=2:(info.N+1)
            %wfm curve information
            frames.(['frame' num2str(frm)]).info.state_flags = fread(fid,1,'*uint32',byteorder);
            frames.(['frame' num2str(frm)]).info.type_of_checksum = fread(fid,4,'*int8',byteorder);
            frames.(['frame' num2str(frm)]).info.checksum = fread(fid,1,'*int16',byteorder);
            frames.(['frame' num2str(frm)]).info.precharge_start_offset = fread(fid,1,'*uint32',byteorder);
            frames.(['frame' num2str(frm)]).info.data_start_offset = fread(fid,1,'uint32',byteorder); %do not convert to same type, since required as double later
            frames.(['frame' num2str(frm)]).info.postcharge_start_offset = fread(fid,1,'uint32',byteorder); %do not convert to same type, since required as double later
            frames.(['frame' num2str(frm)]).info.postcharge_stop_offset = fread(fid,1,'*uint32',byteorder);
            frames.(['frame' num2str(frm)]).info.end_of_curve_buffer_offset = fread(fid,1,'*uint32',byteorder);
        end
    else
        frames=[];
    end
end

switch info.ed1.format(1) %choose correct data format for reading in curve buffer data
    case 0
        format='*int16';
    case 1
        format='*int32';
    case 2
        format='*uint32';
    case 3
        format='*uint64';  %may not work properly. Bug in Matlab or not available in 32-bit Windows? Does not convert to uint64, but to double instead.
    case 4
        format='*float32';
    case 5
        format='*float64';
    case 6
        if (wfm_version >= 3)
            format='*uint8';
        else
            error(['invalid data format or error in file ' filename]);
        end
    case 7
        if (wfm_version >= 3)
            format='*int8';
        else
            error(['invalid data format or error in file ' filename]);
        end
    otherwise
        error(['invalid data format or error in file ' filename]);
end

%read the curve data (first frame only if file contains fast frame data)

%jump to the beginning of the curve buffer
offset = double(info.byte_offset_to_beginning_of_curve_buffer+info.data_start_offset+(startind-1)*info.num_bytes_per_point);
byte_offset_nextframe=info.byte_offset_to_beginning_of_curve_buffer+info.end_of_curve_buffer_offset; %byte offset for the next frame (if it exists)
fseek(fid, offset,'bof');

%read the curve buffer portion which is displayed on the scope only
%(i.e. drop precharge and postcharge points)
nop_all=(info.postcharge_start_offset-info.data_start_offset)/info.num_bytes_per_point; %number of data points stored in the file

nop=nop_all-startind+1;
if nargin>=2
    if datapoints<1 || (round(datapoints)~=datapoints)
        datapoints=floor(nop/step); % set to maximum number of data points which can be securely read from the file, using startind and step parameters
        warning('WFM2read:datapointsPosInt',['"datapoints" input parameter must be a positive integer.\nSetting datapoints= ' num2str(datapoints) '.']);
    end
    nop = floor(nop/step); %maximum number of data points which can be securely read from the frame in the file, using startind and step parameters
    if datapoints > nop %if more datapoints are requested than provided in the file
        warning('WFM2read:inconsistent_params',['The requested combination of input parameters \n' ...
            'datapoints, step and startind would require at least ' num2str(datapoints*step+startind) ' data points in \n'...
            fname '\nThe actual number of data points in the trace \nis only ' num2str(nop_all) '. ' ...
            'The number of data points returned by wfm2read is thus \n' ...
            'only ' num2str(nop) ' instead of ' num2str(datapoints) '.']);
    else
        nop=datapoints;
    end
end

values=double(fread(fid,nop,format,info.num_bytes_per_point*(step-1),byteorder));%#ok %read data values from curve buffer
t = info.id1.dim_offset + info.id1.dim_scale * (startind+(1:step:(nop*step))'-1);
y = info.ed1.dim_offset + info.ed1.dim_scale *values;  %scale data values to obtain in correct units

%handling over- and underranged values
ind_over=find(values==info.ed1.over_range); %find indices of values that are larger than the AD measurement range (upper limit)
ind_under=find(values<=-info.ed1.over_range);%find indices of values that are larger than the AD measurement range (lower limit)

info.yunit = info.ed1.units;
info.tunit = info.id1.units;
info.yres = info.ed1.dim_resolution;
info.samplingrate = 1/info.id1.dim_scale;
info.nop = nop;

%print warning if there are wrong values because they are lying outside
%the AD converter digitization window:
if length(ind_over) %#ok
    warning('WFM2read:OverRangeValues',[int2str(length(ind_over)), ' over range value(s) in file ' filename]); %#ok
end
if length(ind_under) %#ok
    warning('WFM2read:UnderRangeValues',[int2str(length(ind_under)), ' under range value(s) in file ' filename]); %#ok
end

if (info.N>0) && (nargout==6) %if file contains fast frame data and it is requested as output
    %copy data for first frame to the frame struct
    frames.frame1.y=y;
    frames.frame1.t=t;
    frames.frame1.ind_over=ind_over;
    frames.frame1.ind_under=ind_under;

    %get data for all remaining frames:
    for frm=2:(info.N+1)
        %jump to the beginning of the curve buffer for the current frame
        offset = double(byte_offset_nextframe+frames.(['frame' num2str(frm)]).info.data_start_offset+(startind-1)*info.num_bytes_per_point);
        byte_offset_nextframe=byte_offset_nextframe+frames.(['frame' num2str(frm)]).info.end_of_curve_buffer_offset; %byte offset for the next frame (if it exists)
        %read the curve buffer portion which is displayed on the scope only
        %(i.e. drop precharge and postcharge points)
        nop_all=(frames.(['frame' num2str(frm)]).info.postcharge_start_offset-frames.(['frame' num2str(frm)]).info.data_start_offset)/info.num_bytes_per_point; %number of data points stored in the frame
        fseek(fid, offset,'bof');
        nop=nop_all-startind+1;
        if nargin>=2
            nop = floor(nop/step); %maximum number of data points which can be securely read from the frame in the file, using startind and step parameters
            if datapoints > nop %if more datapoints are requested than provided in the file
                %don't display warning again for the other frames, it has already been
                %displayed for the first frame.
                %         warning('Wfm2read:inconsistent_params',['The requested combination of input parameters \n' ...
                %             'datapoints, step and startind would require at least ' num2str(datapoints*step+startind-1) ' data points in \n'...
                %             fname '\nThe actual number of data points in the trace \nis only ' num2str(nop_all) '. ' ...
                %             'The number of data points returned by wfm2read is thus \n' ...
                %             'only ' num2str(nop) ' instead of ' num2str(datapoints) '.']);
            else
                nop=datapoints;
            end
        end

        values=double(fread(fid,nop,format,info.num_bytes_per_point*(step-1),byteorder));%#ok %read data values from curve buffer

        frames.(['frame' num2str(frm)]).y = info.ed1.dim_offset + info.ed1.dim_scale *values;  %scale data values to obtain in correct units
        frames.(['frame' num2str(frm)]).t = info.id1.dim_offset + info.id1.dim_scale * (startind+(1:step:(nop*step))'-1)-double(info.GMT_sec)-info.frac_sec+double(frames.(['frame' num2str(frm)]).info.GMT_sec)+frames.(['frame' num2str(frm)]).info.frac_sec+(-info.tt_offset+frames.(['frame' num2str(frm)]).info.tt_offset)*info.id1.dim_scale;

        %handling over- and underranged values
        frames.(['frame' num2str(frm)]).ind_over=find(values==info.ed1.over_range); %find indices of values that are larger than the AD measurement range (upper limit)
        frames.(['frame' num2str(frm)]).ind_under=find(values<=-info.ed1.over_range);%find indices of values that are larger than the AD measurement range (lower limit)

        %print warning if there are wrong values because they are lying outside
        %the AD converter digitization window:
        if length(frames.(['frame' num2str(frm)]).ind_over) %#ok
            warning('WFM2read:OverRangeValues',[int2str(length(frames.(['frame' num2str(frm)]).ind_over)), ' over range value(s) in file ' filename ', frame ' num2str(frm)]); %#ok
        end
        if length(frames.(['frame' num2str(frm)]).ind_under) %#ok
            warning('WFM2read:UnderRangeValues',[int2str(length(frames.(['frame' num2str(frm)]).ind_under)), ' under range value(s) in file ' filename ', frame ' num2str(frm)]); %#ok
        end
    end
end
fclose(fid);


