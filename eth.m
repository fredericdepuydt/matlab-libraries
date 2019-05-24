%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %%                          ETH PACKET CLASS                          %%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    Author: Frederic Depuydt                                          %
%  %    Company: KU Leuven                                                %
%  %    Contact: frederic.depuydt@kuleuven.be; f.depuydt@outlook.com      %
%  %    Version: 1.1                                                      %
%  %                                                                      %
%  %    An ETHERNET class to analyse packets from Wireshark               %
%  %    and some Tektronix Osciloscopes.                                  %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        FUNCTIONS (static)                 *Object creation*          %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    usage: objEth = eth.function(var1, var2, ...)                     %
%  %                                                                      %
%  %    csvread(                Reading an EVENT TABLE CSV file           %
%  %        file,                   Filename + extension as String        %
%  %        verbose)                Integer to enable verbose mode        %
%  %                                                                      %
%  %    pcapread(               Reading a Wireshark PCAP file             %
%  %        file,                   Filename + extension as String        %
%  %        verbose,                Integer to enable verbose mode        %
%  %        captureFilter)          Wireshark filter as String            %
%  %                                                                      %
%  %    scoperead(              Reading a Scope object                    %
%  %        objScope,               Scope object to read                  %
%  %        verbose)                Integer to enable verbose mode        %
%  %                                                                      %
%  %    scoperead(              Reading a Scope object                    %
%  %        objScope,               Scope object to read                  %
%  %        parameter,              A certain parameter                   %
%  %        value,                  Value for the parameter               %
%  %        ...)                Possible parameters:                      %
%  %                                  'verbose', 'threshold',             %
%  %                                  'cut_off_frequency'                 %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        FUNCTIONS (non-static)                                        %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    usage: objEth.function(var1, var2, ...)                           %
%  %                                                                      %
%  %    plot(                   Plotting Ethernet Packets in Time         %
%  %        offset_x,                                                     %
%  %        offset_y,                                                     %
%  %        lineWidth,                                                    %
%  %        line_color)                                                   %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    VERBOSE MODE: (default=-1)                                        %
%  %        all static functions check for a verbose variable             %
%  %        to enable or disable display output to the console            %
%  %                                                                      %
%  %    verbose ==  0;  % Display output disabled                         %
%  %    verbose == -1;  % Display output enabled for all nested functions %
%  %    verbose ==  x;  % Display output enabled for x nested functions   %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef eth < handle
    properties
        packetNum
        packetLen
        frame
        time
        dstMac
        srcMac
        EthertypeOrLength
        APDU
        EtherTypeSpecificData
        VLANTAG
        packetDesc
        CRC
    end
    properties (Hidden)
        raw
        time_end
    end
    methods
        function obj = eth(num)
            obj.packetNum = num;
        end
        % Converting MAC addresses to hexademical format
        %     dstMacStr = dec2hex(packetData(1:6),2)';
        %     dstMacStr = sprintf('%c%c:',dstMacStr(1:end));
        %     dstMacStr = dstMacStr(1:end-1);
        %     srcMacStr = dec2hex(packetData(7:12),2)';
        %     srcMacStr = sprintf('%c%c:',srcMacStr(1:end));
        %     srcMacStr = srcMacStr(1:end-1);

        
        function plot(obj,offset_x,offset_y, lineWidth, line_color)
            %rectangle('Position' , [offset_x+obj(1).time,offset_x+obj(end).time_end],[offset_y,offset_y],'Color','black','LineWidth',lineWidth/10);
            defaultFaceColor = line_color;
            defaultEdgeColor = [0 0 0];
            IFGFaceColor = [0.9 0.9 0.9];
            IFGEdgeColor = [0.6 0.6 0.6];
            for i=1:length(obj)
                FaceColor = defaultFaceColor;
                EdgeColor = defaultEdgeColor;
                TimeStart = offset_x+obj(i).time;
                TimeEnd = offset_x+obj(i).time + (obj(i).packetLen)*8*10e-9;
                if(obj(i).EthertypeOrLength == '0x8892')
                    if(obj(i).EtherTypeSpecificData.PNIO_FrameID == 'FE01')
                       FaceColor = [255 223 223]/255;
                       EdgeColor = [255 0 0]/255;
                    end
                end
                %% IFG
                rectangle ( 'Position' , [TimeEnd offset_y-(lineWidth/2) (12*8*10e-9) lineWidth],...
                    'FaceColor' , IFGFaceColor,...
                    'EdgeColor', IFGEdgeColor);
                %% PACKET
                rectangle ( 'Position' , [TimeStart offset_y-(lineWidth/2) (TimeEnd-TimeStart) lineWidth],...
                    'FaceColor' , FaceColor,...
                    'EdgeColor', EdgeColor);
                
            end
        end
    end
    methods (Static)
        %% FUNCTION - CSV READ
        % HELP
        function obj = csvread(file,verbose)
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if ~exist('file','var')
                % Ask user for file name
                % check if file exists
            end
            fileID = fopen(file);
            textscan(fileID, '%s',51,'HeaderLines',2,'Delimiter',',');
            data = textscan(fileID, '%f %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %*[^\n]','Delimiter',',');
            fclose(fileID);
            
            packetNum = length(data{1});
            
            obj = eth.empty(packetNum,0); %% Preallocating variable size
            for k=1:packetNum
                % Converting data fields to byte arrays
                data{50}{k} = strsplit(data{50}{k},' ');
                % Converting data bytefields to decimal numbers
                data{50}{k} = hex2dec(data{50}{k});
                % Passing needed info to the object array
                obj(k) = eth(k);
                obj(k).time = data{1}(k);
                obj(k).dstMac = hex2dec(strsplit(data{2}{k},':'));
                obj(k).srcMac = hex2dec(strsplit(data{3}{k},':'));
                if data{4}{k}
                    obj(k).VLANTAG.QTag = data{4}{k};
                    obj(k).VLANTAG.QTagCtrl = data{5}{k};
                    obj(k).packetLen = 8 + 4 + 6 + 6 + 4 + 2 + length(data{50}{k});
                else
                    obj(k).packetLen = 8 + 4 + 6 + 6 + 2 + length(data{50}{k});
                end
                obj(k).EthertypeOrLength = ['0x' data{6}{k}];
                if data{18}{k}
                    obj(k).EtherTypeSpecificData.dstIP = data{18}{k};
                    obj(k).EtherTypeSpecificData.srcIP = data{17}{k};
                end
                obj(k).APDU = data{50}{k};
                
            end
            
            if verbose
                disp(['Ethernet packets read from ' file '.']);
                disp(['   * ' num2str(length(obj)) ' ethernet packets']);
                % Some extra info on how many UDP / TCP / PROFINET packets
            end
            
        end
        
        function obj = pcapread(file,verbose,captureFilter)
            %% FUNCTION - PCAPNG READ
            % Set tshark correct path to let user use pre-filtering
            % ethObj = eth.csvread(filename, silent_mode)
            % ethObj = eth.pcapread(filename, silent_mode, capture_filter)
            %
            % filename — mandatory function argument, string.
            % Examples: "snap.pcapng", "data/measurements/fullsnap.csv"
            %
            % silent_mode - optional argument for displaying extra information to console, int, 1 - keep console clean, 0 - show extra information about files being read
            % Examples: 1, 0.
            %
            % capture_filter — actual for pcapread. You should set a valid path to TShark.exe at the beginning of pcapread function to make this option work.
            % Examples: "eth.src == 68:05:ca:1e:84:69 & !udp"
            
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            
            
            while ~exist('file','var')
                file = input ('Enter a full filepath.');
            end
            
            % Include right path to Tshark.exe below
            if ~exist('captureFilter','var')
                captureFilter='';
            else
                tsharkPath = '"C:\Program Files\Wireshark\tshark.exe"';
                filePath = sprintf('"%s"', file);
                fileTemp = '"ethTempFile.pcapng"';
                filter = sprintf('"%s"',captureFilter);
                status = system(sprintf('%s -r %s -Y %s -F pcapng -w %s', tsharkPath, filePath, filter, fileTemp));
            end;
            
            % Reading from raw or filtered data depending on status variable
            if ~exist('status','var')
                fileID = fopen(file);
            elseif status == 0
                disp (['Filter: ', captureFilter]);
                fileID = fopen(strrep(fileTemp,'"',''));
            else
                error ('Invalid filter name.');
            end
            
            % File is stored as decimal numbers
            data = fread(fileID)';
            fclose('all');
            
            if exist('status','var') && status == 0
                % Delete temporary file
                delete('ethTempFile.pcapng');
            end
            
            if verbose
                s = dir(file);
                fileSizeMb = s.bytes/1024/1024;
                disp(sprintf('Filesize of ''%s'': %.3g MB', file, fileSizeMb));
            end
            
            %% Constants
            sectHeaderBlock = 168627466; % hex2dec('0A0D0D0A');
            enhPacketBlock = 6; % hex2dec('00000006');
            ifDescBlock = 1; % hex2dec('00000001');
            simplePacketBlock = 3; % hex2dec('00000003');
            obsoletePacketBlock = 2; % hex2dec('00000002');
            
            % PCAPNG ORDER
            byteOrderBigPCAPNG = 439041101; % hex2dec('1A2B3C4D');
            byteOrderLittlePCAPNG = 1295788826; % hex2dec('4D3C2B1A');
            % PCAP ORDER (Timestamps in �s)
            byteOrderBigPCAP = 2712847316; % hex2dec('A1B2C3D4');
            byteOrderLittlePCAP = 3569595041; % hex2dec('D4C3B2A1');
            % PCAP ORDER (Timestamps in ns)
            byteOrderBigPCAP_ns = 2712812621; % hex2dec('A1B23C4D');
            byteOrderLittlePCAP_ns = 1295823521; % hex2dec('4D3CB2A1');
            
            %% PCAP OR PCAPNG
            pcapng = 0; timestamp_ns = 0;
            byteOrder = sum(data(1:4).*[2^24,2^16,2^8,2^0]);
            
            switch(byteOrder)
                case byteOrderBigPCAP
                    byteOrder = 1; % big-endian
                    if(verbose);disp('PCAP Big-endian');end;
                case byteOrderLittlePCAP
                    byteOrder = 0; % little-endian
                    if(verbose);disp('PCAP Little-endian');end;
                case byteOrderBigPCAP_ns
                    timestamp_ns = 1;
                    byteOrder = 1; % little-endian
                    if(verbose);disp('PCAP Little-endian (ns)');end;
                case byteOrderLittlePCAP_ns
                    timestamp_ns = 1;
                    byteOrder = 0; % little-endian
                    if(verbose);disp('PCAP Little-endian (ns)');end;
                otherwise
                    pcapng = 1;
                    if(verbose);disp('PCAPNG');end;
            end
            
            %% Initialize some variables
            idx = 1;
            packetNum = 0;
            blockNum = 0;
            simplePacketBlockNum = 0;
            
            %% Get an exact quantity of enhanced packets to preallocate memory
            while (idx<length(data))
                if pcapng
                    blockType = data(idx:idx+3);
                    if sum(blockType.*[2^24,2^16,2^8,2^0]) == sectHeaderBlock
                        byteOrderMagic = sum(data(idx+8:idx+11).*[2^24,2^16,2^8,2^0]);
                        if byteOrderMagic == byteOrderBigPCAPNG
                            byteOrder = 1; % big-endian
                            if(verbose);disp('Big endian');end;
                        elseif byteOrderMagic == byteOrderLittlePCAPNG
                            byteOrder = 0; % little-endian
                            if(verbose);disp('Little endian');end;
                        else
                            if(verbose);disp('No endian');end;
                        end
                    elseif sum(blockType.*[2^24,2^16,2^8,2^0]) == simplePacketBlock
                        simplePacketBlockNum=simplePacketBlockNum+1;
                        if(verbose);disp(['Simple Packet Block: ' num2str(packetNum)]);end;
                    else
                        if(verbose);disp(['Unknown Block: ' dec2hex(sum(blockType.*[2^24,2^16,2^8,2^0]))]);end;
                    end
                    if byteOrder
                        lengthStart = data(idx+4:idx+7);
                        blockLength = sum(lengthStart.*[2^24,2^16,2^8,2^0]);
                        blockType = data(idx:idx+3);
                        lengthEnd = data(idx+blockLength-4:idx+blockLength-1);
                    else
                        lengthStart = data(idx+7:-1:idx+4);
                        blockLength = sum(lengthStart.*[2^24,2^16,2^8,2^0]);
                        blockType = data(idx+3:-1:idx);
                        lengthEnd = data(idx+blockLength-1:-1:idx+blockLength-4);
                    end
                    % Check block length at start and at the end
                    if lengthStart~=lengthEnd
                        error('Packet size mismatch. Function terminated.');
                    end
                    lengthStart = data(idx+4:idx+7);
                    blockLength = sum(lengthStart.*[2^0,2^8,2^16,2^24]);
                    blockNum = blockNum + 1;
                    if sum(blockType.*[2^24,2^16,2^8,2^0]) == enhPacketBlock
                        packetNum = packetNum + 1;
                    end
                    idx = idx + blockLength;
                else
                    %Reading Global Header information (for future usage)
                    if byteOrder
                        GlobalHeader.magic_number = dec2hex(sum(data(1:4).*[2^24,2^16,2^8,2^0]));
                        GlobalHeader.version_major = data(5:6);
                        GlobalHeader.version_minor = data(7:8);
                        GlobalHeader.thiszone = typecast(uint32(sum(data(9:12).*[2^24,2^16,2^8,2^0])),'int32');
                        GlobalHeader.sigfigs = data(12:16);
                        GlobalHeader.snaplen = data(17:20);
                        GlobalHeader.network = sum(data(21:24).*[2^24,2^16,2^8,2^0])
                    else
                        GlobalHeader.magic_number = dec2hex(sum(data(4:-1:1).*[2^24,2^16,2^8,2^0]));
                        GlobalHeader.version_major = data(6:-1:5);
                        GlobalHeader.version_minor = data(8:-1:7);
                        GlobalHeader.thiszone = typecast(uint32(sum(data(12:-1:9).*[2^24,2^16,2^8,2^0])),'int32');
                        GlobalHeader.sigfigs = data(16:-1:12);
                        GlobalHeader.snaplen = data(20:-1:17);
                        GlobalHeader.network = sum(data(24:-1:21).*[2^24,2^16,2^8,2^0])
                    end
                    if(verbose);assignin('base', 'pcap_header', GlobalHeader);end;
                    idx = 25;
                    % Obtaining exact packet number
                    while idx < length(data)
                        if byteOrder
                            SnapshotLength = sum(data(idx+8:idx+11).*[2^24,2^16,2^8,2^0]);
                        else
                            SnapshotLength = sum(data(idx+11:-1:idx+8).*[2^24,2^16,2^8,2^0]);
                        end
                        packetNum = packetNum + 1;
                        idx = idx + 16 + SnapshotLength;
                    end
                end
            end
            
            if simplePacketBlockNum>0
                disp(['This pcap file contains', num2str(simplePacketBlock), 'that are not displayed.']);
            end
            %% Preallocating memory
            obj = eth.empty(packetNum,0);
            % Data from pcap files will present only repeated headers and data
            if ~pcapng
                data = data (25:end);
            end
            %% Default values below
            idx = 1; byteOrder = 0; packetNum = 1; packetData = [];
            
            while idx<length(data)
                if pcapng
                    blockType = data(idx:idx+3);
                    % If there is a new Section Header Block
                    % the statements below will check the byte order
                    if sum(blockType.*[2^24,2^16,2^8,2^0]) == sectHeaderBlock
                        byteOrderMagic = sum(data(idx+8:idx+11).*[2^24,2^16,2^8,2^0]);
                        if byteOrderMagic == byteOrderBigPCAPNG
                            byteOrder = 1; % big-endian
                        elseif byteOrderMagic == byteOrderLittlePCAPNG
                            byteOrder = 0; % little-endian
                        end
                    end
                    
                    % Assigning block type, length variables
                    if byteOrder == 1
                        lengthStart = data(idx+4:idx+7);
                        blockLength = sum(lengthStart.*[2^24,2^16,2^8,2^0]);
                        blockType = data(idx:idx+3);
                    else
                        lengthStart = data(idx+7:-1:idx+4);
                        blockLength = sum(lengthStart.*[2^24,2^16,2^8,2^0]);
                        blockType = data(idx+3:-1:idx);
                    end
                    pcapBody = data(idx+8:idx+blockLength-5);
                end
                
                %packetNum = packetNum + 1;
                
                if (~pcapng || sum(blockType.*[2^24, 2^16, 2^8, 2^0]) == enhPacketBlock ...
                        || sum(blockType.*[2^24, 2^16, 2^8, 2^0]) == obsoletePacketBlock )
                    %Reading Ethernet information from PCAP or PCAPNG files
                    obj(packetNum) = eth(packetNum);
                    
                    if pcapng
                        %Extracting information from pcapng
                        if byteOrder == 0
                            capturedLen = pcapBody(16:-1:13);
                            packetLen = pcapBody(20:-1:17);
                            dataLength = sum(capturedLen.*[2^24,2^16,2^8,2^0]);
                            packetData = pcapBody(21:21+dataLength-1);
                            timestampHigh = pcapBody(8:-1:5);
                            timestampLow = pcapBody(12:-1:9);
                        else
                            capturedLen = pcapBody(13:16);
                            packetLen = pcapBody(17:20);
                            dataLength = sum(capturedLen.*[2^24,2^16,2^8,2^0]);
                            packetData = pcapBody(21:21+dataLength-1);
                            timestampHigh = pcapBody(5:8);
                            timestampLow = pcapBody(9:12);
                        end
                        
                        if isfield(OptionStruct,'if_tsresol')
                            obj(packetNum).time = (sum(timestampHigh.*[2^56,2^48,2^40,2^32])+sum(timestampLow.*[2^24,2^16,2^8,2^0]))/10^OptionStruct.if_tsresol;
                            % obj(packetNum).time = datestr(obj(packetNum).time/86400 + datenum(1970,1,1));
                        else
                            obj(packetNum).time = (sum(timestampHigh.*[2^56,2^48,2^40,2^32])+sum(timestampLow.*[2^24,2^16,2^8,2^0]))/10^6;
                            % obj(packetNum).time = datestr(obj(packetNum).time/86400 + datenum(1970,1,1));
                        end
                        %obj(enhPacketNum).time = datestr(sum(blockBody(12:-1:5).*[2^24; 2^16; 2^8, 2^0; 2^56; 2^48; 2^40; 2^32])/86400/10^6 + datenum(1970,1,1));
                    else
                        %Extracting information from pcap
                        if byteOrder == 0
                            TimestampSec = sum(data(idx+3:-1:idx).*[2^24,2^16,2^8,2^0]);
                            TimestampMicroSec = sum(data(idx+7:-1:idx+4).*[2^24,2^16,2^8,2^0]);
                            SnapshotLength = sum(data(idx+11:-1:idx+8).*[2^24,2^16,2^8,2^0]);
                            CapturedLen = data(idx+15:-1:idx+12);
                        else
                            TimestampSec = sum(data(idx:idx+3).*[2^24,2^16,2^8,2^0]);
                            TimestampMicroSec = sum(data(idx+4:idx+7).*[2^24,2^16,2^8,2^0]);
                            SnapshotLength = sum(data(idx+8:idx+11).*[2^24,2^16,2^8,2^0]);
                            CapturedLen = data(idx+12:idx+15);
                        end
                        
                        if(timestamp_ns)
                            if(packetNum == 1)
                                StartTimestampSec = TimestampSec;
                                StartTimestampMicroSec = TimestampMicroSec;
                                obj(packetNum).time = 0;
                            else
                                obj(packetNum).time = (TimestampSec-StartTimestampSec) + ((TimestampMicroSec-StartTimestampMicroSec)*1e-9);
                            end
                            
                        else
                            if(packetNum == 1)
                                StartTimestampSec = TimestampSec;
                                StartTimestampMicroSec = TimestampMicroSec;
                                obj(packetNum).time = 0;
                            else
                                obj(packetNum).time = (TimestampSec-StartTimestampSec) + ((TimestampMicroSec-StartTimestampMicroSec)*1e-6);
                            end
                        end
                        
                        switch (GlobalHeader.network)
                            case 1
                                % Normal Ethernet Packet
                                obj(packetNum).frame.encapsulation_type = 1;
                                obj(packetNum).frame.encapsulation_desc = 'Ethernet';
                                packetData = data(idx+16:idx+16+SnapshotLength-1);
                            case 240
                                % netANALYZER
                                obj(packetNum).frame.encapsulation_type = 135;
                                obj(packetNum).frame.encapsulation_desc = 'netANALYZER';
                                obj(packetNum).frame.netANALYZER.Status = data(idx+16);
                                obj(packetNum).frame.netANALYZER.Reception_Port = floor(data(idx+17)/64);
                                obj(packetNum).frame.netANALYZER.Ethernet_frame_length = data(idx+18);
                                obj(packetNum).frame.netANALYZER.Type = mod(data(idx+17),64);
                                switch(obj(packetNum).frame.netANALYZER.Type)
                                    case 4
                                        packetData = data(idx+20:idx+12+SnapshotLength-1);
                                        obj(packetNum).CRC = data(idx+12+SnapshotLength:idx+15+SnapshotLength);
                                    case 5
                                        obj(packetNum).frame.netANALYZER.Event_on = data(idx+35);
                                        obj(packetNum).frame.netANALYZER.Event_type = data(idx+36);
                                    otherwise
                                        warn('Unknown netANALYZER Packet Type (GPIO?)');
                                        obj(packetNum).frame.error = 'Unknown netANALYZER Packet Type (GPIO?)';
                                end
                            otherwise
                                warn('Unknown encapsulation');
                                obj(packetNum).frame.error = 'Unknown encapsulation';
                        end
                    end
                    if(~isempty(packetData))
                        obj(packetNum).readByteStream(packetData);
                        obj(packetNum).time_end = obj(packetNum).time + obj(packetNum).packetLen*8*10e-9;
                    end
                    packetData = [];
                    packetNum = packetNum + 1;
                    %PCAP(packetNum).body.absTime = datestr(PCAP(packetNum).body.Timestamp/86400/10^6 + datenum(1970,1,1));
                elseif pcapng && sum(blockType.*[2^24,2^16,2^8,2^0]) == ifDescBlock                    
                    %Extracting data from interface description block
                    if byteOrder
                        LinkType = pcapBody(1:2);
                        SnapLen = pcapBody(5:8);
                    else
                        LinkType = pcapBody(2:-1:1);
                        SnapLen = pcapBody(8:-1:5);
                    end
                    OptionStruct = struct(...
                        'LinkType', LinkType', ...
                        'SnapLen', sum(SnapLen.*[2^24,2^16,2^8,2^0])...
                        );
                    if length(pcapBody)>8
                        %Reading options from this packet
                        i = 9;
                        while i<length(pcapBody)
                            
                            if byteOrder
                                optionCode = pcapBody(i:i+1);
                                optionLength = sum(pcapBody(i+2:i+3).*[2^8,2^0]);
                            else
                                optionCode = pcapBody(i+1:-1:i);
                                optionLength = sum(pcapBody(i+3:-1:i+2).*[2^8,2^0]);
                            end
                            
                            % Padding calculation
                            if rem(optionLength,4)
                                optionLengthWithPadding = optionLength + 4 - rem(optionLength,4);
                            else
                                optionLengthWithPadding = optionLength;
                            end
                            %% Saving option structure
                            switch optionCode(2)
                                case 1
                                    optionValue = char(pcapBody(i+4:i+4+optionLength-1))';
                                    OptionStruct.comment = OptionStruct.comment + optionValue;
                                case 2
                                    optionValue = pcapBody(i+4:i+4+optionLength-1);
                                    OptionStruct.if_name = char(optionValue);
                                case 4
                                    optionValue = pcapBody(i+4:i+4+optionLength-1);
                                    OptionStruct.if_IPv4addr = optionValue;
                                case 5
                                    optionValue = pcapBody(i+4:i+4+optionLength-1);
                                    OptionStruct.if_IPv6addr = optionValue;
                                case 6
                                    optionValue = pcapBody(i+4:i+4+optionLength-1);
                                    OptionStruct.if_EUIaddr = optionValue;
                                case 8
                                    optionValue = pcapBody(i+4:i+4+optionLength-1);
                                    OptionStruct.if_speed = optionValue;
                                case 9
                                    optionValue = pcapBody(i+4:i+4+optionLength-1);
                                    OptionStruct.if_tsresol = optionValue;
                                case 10
                                    optionValue = pcapBody(i+4:i+4+optionLength-1);
                                    OptionStruct.if_tzone = optionValue;
                                case 11
                                    optionValue = pcapBody(i+4:i+4+optionLength-1);
                                    OptionStruct.if_filter = char(optionValue');
                                case 12
                                    optionValue = pcapBody(i+4:i+4+optionLength-1);
                                    OptionStruct.if_os = char(optionValue');
                                case 13
                                    optionValue = pcapBody(i+4:i+4+optionLength-1);
                                    OptionStruct.if_fcslen = optionValue;
                                case 14
                                    optionValue = pcapBody(i+4:i+4+optionLength-1);
                                    OptionStruct.if_fcslen = optionValue;
                            end
                            
                            if optionCode(2)
                                i = i + 4 + optionLengthWithPadding;
                            else
                                i =  length(pcapBody)+10;
                            end
                            
                        end
                    end
                    if(verbose);assignin('base', 'pcap_options', OptionStruct);end;
                    end
                    
                if pcapng
                    idx = idx + blockLength;
                else
                    idx = idx + 16 + SnapshotLength;
                end
            end
            if(verbose);disp(['Total file size is: ', num2str(fileSizeMb), ' MB']);end;
        end
        
        %% FUNCTION - Scope READ
        function obj = scoperead(varargin)
            if(nargin >= 1)
                if(isa(varargin{1}, 'scope'))
                    objScope = varargin{1};
                else
                    error('Need a scope object as first input');
                end
                if(nargin >= 2)
                    if(isa(varargin{2}, 'double') && nargin==2)
                        verbose = varargin{2};
                    else
                        varargin(1) = [];
                        while ~isempty(varargin)
                            if(isstruct(varargin{1}))
                                var = varargin{1};
                                fields = fieldnames(var);
                                varargin(length(fields)*2+1:end+length(fields)*2-1)=varargin(2:end);
                                for i = 1:numel(fields)
                                    varargin(i*2-1)=fields(i);
                                    varargin{i*2}=var.(char(fields(1)));
                                end
                            elseif(ischar(varargin{1}))
                                switch lower(varargin{1})
                                    case 'verbose'
                                        verbose = varargin{2};
                                        varargin(1:2) = [];
                                    case 'threshold'
                                        threshold = varargin{2};
                                        varargin(1:2) = [];
                                    case 'cut_off_frequency'
                                        cut_off_frequency = varargin{2};
                                        varargin(1:2) = [];
                                    otherwise
                                        warn('Unknown argument');
                                        varargin(1) = [];
                                end
                            else
                                warn('Unknown argument');
                                varargin(1) = [];
                            end
                        end
                    end
                end
            end
            
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if(~exist('threshold','var'));threshold=0.5;end;
            if(~exist('cut_off_frequency','var'));cut_off_frequency=2*125e6;end;
            
            objPHY = ethPHYdecode(objScope,'threshold',threshold,'cut_off_frequency',cut_off_frequency,'verbose',verbose-(verbose>0));
            
            X = objPHY.time;
            Y = objPHY.value;
            
            SSD = find(Y(1:end-1)==-1 & Y(2:end)==-2);
            ESD = find(Y(1:end-1)==-3 & Y(2:end)==-4);
            
            
            if(SSD(1)>ESD(1));ESD(1)=[];end; % removing early End Delimiters
            if(ESD(end)<SSD(end));SSD(end)=[];end; % removing late Start Delimiters
            
            %% Preallocating memory
            obj = eth.empty(0,length(SSD));
            packetNum = 1;
            for i=SSD
                j = i+find(Y(i:end)==-3,1)-1;
                if(~isempty(j))
                    NibbleData = Y(i+2:j-1);
                    if(mod(length(NibbleData),2)==0 && ~range(NibbleData<16 & NibbleData>=0))
                        % CRC is ignored atm
                        packetData = NibbleData(15:2:end-8)+NibbleData(16:2:end-8)*16;                        
                        obj(packetNum) = eth(packetNum);
                        obj(packetNum).CRC = NibbleData(end-7:2:end)+NibbleData(end-6:2:end)*16;
                        obj(packetNum).time = X(i);
                        obj(packetNum).readByteStream(packetData);
                        obj(packetNum).time_end = obj(packetNum).time + obj(packetNum).packetLen*8*10e-9;
                        obj(packetNum).frame.encapsulation_type = 1;
                        packetNum = packetNum + 1;
                    end
                end
            end
        end
    end
    methods
        function result = filter(obj, filterStr)
            %expression = '\s*(!|)\s*(da|DA|sa|SA|fc|FC|sd|SD|illegal)\s*(=|<>|)\s*(\d*)\s*(\&\&|and|AND|\|\||or|OR|)';
            expression = '\s*(!|)\s*(eth\.src|eth\.dst|eth\.addr)\s*(==|!=|eq)\s*([0-9a-fA-F]{1,2}[:-][0-9a-fA-F]{1,2}[:-][0-9a-fA-F]{1,2}[:-][0-9a-fA-F]{1,2}[:-][0-9a-fA-F]{1,2}[:-][0-9a-fA-F]{1,2})\s*(\&\&|and|AND|\|\||or|OR|)';
            [tokens, matches] = regexp(filterStr,expression,'tokens','match');
            findObjFilter = {};
            i = 1;
            if ~isempty(tokens)
                % if there are more than 2 statements provide a logical operators
                % check                
                while i<=length(tokens)
                    clear logicRule;
                    % An information from i-th user filter statement
                    precedingSign = tokens{i}{1};
                    filterName = tokens{i}{2};
                    equalSign = tokens{i}{3};
                    filterValue = tokens{i}{4};
                    if i>1
                        logicalOperator = tokens{i-1}{5};
                        if strcmp(logicalOperator,'&&') || strcmp(logicalOperator,'and') || strcmp(logicalOperator,'AND')
                            logicRule = '-and';
                        elseif strcmp(logicalOperator,'||') || strcmp(logicalOperator,'or') || strcmp(logicalOperator,'OR')
                            logicRule = '-or';
                        else
                            error('No logic rule between statements');
                        end
                    end
                    
                    if strcmp(precedingSign,'!')
                        precedingRule = '-not';
                    else
                        clear precedingRule;
                    end
                    
                    if strcmp(equalSign,'<>')
                        equalRule = '-not';
                    elseif strcmp(equalSign,'!=')
                        equalRule = '-not';
                    elseif strcmp(equalSign,'=')
                        equalRule = '-and';
                    elseif strcmp(equalSign,'==')
                        equalRule = '-and';
                    else
                        equalRule = '-and';
                    end
                    
                    if exist('precedingRule','var')
                        if strcmp(precedingRule,'-not')
                            if strcmp(equalRule,'-not')
                                equalRule = '-and';
                            elseif strcmp(equalRule,'-and')
                                equalRule = '-not';
                            end
                        end
                    end
                    
                    if exist('logicRule','var')
                        findObjFilter = {findObjFilter{:}, logicRule};
                    end
                    
                    if isempty(findObjFilter)
                        findObjFilter = {equalRule};
                    else
                        findObjFilter = {findObjFilter{:}, equalRule};
                    end
                    
                    switch lower(filterName)
                        case {'eth.src'}
                            findObjFilter = {findObjFilter{:}, 'srcMac', str2double(filterValue)};
                        case {'eth.dst'}                            
                            findObjFilter = {findObjFilter{:}, 'dstMac', str2double(filterValue)};
                        
                            %findObjFilter = {findObjFilter{:}, 'dstMac', str2double(filterValue)};
                        %case {'illegal'}
                        %    findObjFilter = {findObjFilter{:}, 'type_id', 0};
                        %case {'fcs'}
                        %    findObjFilter = {findObjFilter{:}, 'type_id', -1};
                        %case {'sap'}
                        %    findObjFilter = {findObjFilter{:}, 'sap', true};
                    end
                    i = i + 1;
                end
                result = findobj(obj,findObjFilter{:})';
            else
                result = {};
            end               
        end
        function readByteStream (obj, packetData)
            % This function reads packet byte stream
            EtherTypeVLAN = [129,0]; % 0x8100
            EtherTypePROFINET = [136,146]; % 0x8892
            EtherTypeIP = [8,0]; % 0x0800
            EtherTypeARP = [8,6]; % 0x0806
            EtherTypeHSR = [137,47]; % 0x892F
            
            % Creating an eth object
            obj.dstMac = packetData(1:6);
            obj.srcMac = packetData(7:12);
            obj.raw = packetData;
            % Calculating a full packet length with preambule and fcs/crc
            obj.packetLen = 8 + length(packetData) + 4;
            
            evaluate = true;
            while(evaluate)     
                evaluate = false;
                if isequal(packetData(13:14),EtherTypeVLAN) % VLAN TAG
                    evaluate = true;
                    QTagCtrlBits = dec2bin(packetData(15:16),8);
                    obj.VLANTAG.QTag = '8100';
                    obj.VLANTAG.Priority = bin2dec(QTagCtrlBits(1,1:3));
                    obj.VLANTAG.Flag = QTagCtrlBits(1,4);
                    obj.VLANTAG.VLAN_ID = bin2dec([QTagCtrlBits(1,5:8) QTagCtrlBits(2,1:8)]);
                    packetData = [packetData(1:12) packetData(17:end)];
                end
                if isequal(packetData(13:14),EtherTypeHSR) % HSR Header            
                    evaluate = true;
                    HSRBits = dec2bin(packetData(15:16),8);
                    obj.EtherTypeSpecificData.HSR.Network = HSRBits(1,1:3);
                    obj.EtherTypeSpecificData.HSR.LSDU = bin2dec([HSRBits(1,5:8) HSRBits(2,1:8)]);
                    obj.EtherTypeSpecificData.HSR.Sequence = sum(packetData(17:18).*[2^8, 2^0]);
                    packetData = [packetData(1:12) packetData(19:end)];
                end
            end
            if sum(packetData(13:14).*[2^8, 2^0]) <= 1500
                obj.EthertypeOrLength = sum(packetData(13:14).*[2^8, 2^0]);
                obj.APDU = packetData(15:end);
            else
                EtherTypeHex = dec2hex(packetData(13:14),2);
                obj.EthertypeOrLength = ['0x' sscanf(EtherTypeHex','%c')];
                obj.APDU = packetData(15:end);
                if isequal(packetData(13:14),EtherTypeARP)                    
                    obj.packetDesc = 'ARP';
                    obj.APDU = packetData(15:end);                    
                elseif isequal(packetData(13:14),EtherTypePROFINET)                    
                    FrameID = sum(packetData(15:16).*[2^8, 2^0]);
                    PNIO_FrameIDHex = dec2hex(packetData(15:16),2);
                    obj.EtherTypeSpecificData.PNIO_FrameID = sscanf(PNIO_FrameIDHex','%c');
                    obj.APDU = packetData(15:end);
                    % Comparing FrameID
                    obj.setFrameID(FrameID, obj.APDU, 0);                    
                elseif isequal(packetData(13:14),EtherTypeIP)

                    % IPv4 packet
                    IPLength = dec2hex(packetData(15));
                    IPLength = hex2dec(IPLength(2))*4; % Obtaining octets length
                    obj.EthertypeOrLength = '0x0800';
                    obj.APDU = packetData(15:end);
                    obj.EtherTypeSpecificData.IP_srcIP = packetData(15+12:15+12+3);
                    obj.EtherTypeSpecificData.IP_dstIP = packetData(15+16:15+16+3);
                    obj.EtherTypeSpecificData.IP_protocol = packetData(15+9);
                    obj.EtherTypeSpecificData.IP_headerLength = IPLength;

                    switch obj.EtherTypeSpecificData.IP_protocol

                        case 17
                            % Reading UDP
                            obj.EtherTypeSpecificData.IP_SpecificData.UDP_srcPort = sum(packetData(15+IPLength:15+IPLength+1).*[2^8,2^0]);
                            obj.EtherTypeSpecificData.IP_SpecificData.UDP_dstPort = sum(packetData(15+IPLength+2:15+IPLength+3).*[2^8,2^0]);
                            obj.EtherTypeSpecificData.IP_SpecificData.UDP_length = sum(packetData(15+IPLength+4:15+IPLength+5).*[2^8,2^0]);
                            % Check if UDP has DCE/RPC protocol
                            UDPdata = packetData(15+IPLength+8:end);
                            RPCbyteOrder = UDPdata(5);

                            if length(UDPdata) >= 80

                                if RPCbyteOrder >= 16
                                    % RPCbyteOrder = 0;
                                    % little-endian byte order
                                    RPCfragmentLength = UDPdata(80-4:-1:80-5);
                                    RPCuuid =  {UDPdata(28:-1:25) UDPdata(30:-1:29) ...
                                        UDPdata(32:-1:31) UDPdata(33:34) ...
                                        UDPdata(35:40)};
                                else
                                    % RPCbyteOrder = 1;
                                    % big-endian byte order
                                    RPCfragmentLength = UDPdata(80-5:80-4);
                                    RPCuuid    =  {UDPdata(25:28) UDPdata(29:30) ...
                                        UDPdata(31:32) UDPdata(34:-1:33) ...
                                        UDPdata(40:-1:35)};
                                end

                                PNIO_RPCuuid = {'DEA00001-6C97-11D1-8271-00A02442DF7D',...
                                    'DEA00002-6C97-11D1-8271-00A02442DF7D',...
                                    'DEA00003-6C97-11D1-8271-00A02442DF7D',...
                                    'DEA00004-6C97-11D1-8271-00A02442DF7D'};
                                RPCfragmentLength = sum(RPCfragmentLength.*[2^8,2^0]);

                                if length(UDPdata) == 80 + RPCfragmentLength
                                    % it is RPC protocol
                                    % checking UUID refers to PN_IO
                                    UUID = strjoin(cellfun(@(x) sprintf('%s',dec2hex(x,2)'),RPCuuid, 'UniformOutput', false),'-');
                                    obj.EtherTypeSpecificData.IP_SpecificData.RPCuuid = UUID;
                                    obj.EtherTypeSpecificData.IP_SpecificData.RPCLen = RPCfragmentLength;

                                    if any(strcmp(PNIO_RPCuuid,UUID))
                                        % This is a PN-IO CM packet
                                        obj.packetDesc = 'PN_IO CM';
                                    end

                                end

                            end

                        case 6                            
                            %Reading TCP
                            obj.EtherTypeSpecificData.IP_SpecificData.TCP_srcPort = sum(packetData(15+IPLength:15+IPLength+1).*[2^8,2^0]);
                            obj.EtherTypeSpecificData.IP_SpecificData.TCP_dstPort = sum(packetData(15+IPLength+2:15+IPLength+3).*[2^8,2^0]);
                            obj.EtherTypeSpecificData.IP_SpecificData.TCP_sequenceNumber = packetData(15+IPLength+4:15+IPLength+7);

                        otherwise

                    end
                end
            end
        end
    end
    methods (Access = private)
        function setFrameID (obj, FrameID, APDU, VLAN_exist)
            % This function is used for setting proper packet description in eth objects
            % Frame ID list below
            % PN_AcyclicTimeSync = 127;
            % PN_CyclicTimeSync = 255;
            % PN_RTClass3_Cyclic = 32767;
            % PN_RTClass1_Unicast = 48127;
            % PN_RTClass1_Multicast = 49151;
            % PN_RTClass_UDP_Unicast = 63487;
            % PN_RTClass_UDP_Multicast = 64511;
            % PN_Reserved1 = 64512;
            % PN_IO_Alarm_High = 64513;
            % PN_Reserved2 = 65024;
            % PN_IO_Alarm_Low = 65025;
            % PN_Reserved3 = 65275;
            % PN_DCP = 65279;
            % PN_PTCP = 65375;
            % PN_Reserved4 = 65407;
            % PN_FragmentationFrameID = 65423;
            % PN_Reserved5 = 65535;
            
            % Comparing FrameID
            if FrameID <= 127
                obj.packetDesc = 'PN Acyclic time synchronisation';
            elseif FrameID <= 255
                obj.packetDesc = 'PN Cyclic time synchronisation';
            elseif FrameID <= 49151
                PNIO_FrameIDHex = dec2hex(APDU(1:2),2);
                PNIO_CycleCounter = sum(APDU(end-7:end-6).*[2^8, 2^0]);
                obj.EtherTypeSpecificData.PNIO = true;
                obj.EtherTypeSpecificData.PNIO_FrameID = sscanf(PNIO_FrameIDHex','%c');
                obj.EtherTypeSpecificData.PNIO_CycleCounter = PNIO_CycleCounter;
                obj.EtherTypeSpecificData.PNIO_TransferStatus = APDU(end-4);
                obj.EtherTypeSpecificData.PNIO_UserData = APDU(3:end-4);
                obj.EtherTypeSpecificData.PNIO_DataStatus = dec2bin(APDU(end-1),8);
                if FrameID <= 32767
                    obj.packetDesc = 'RT class 3 frames, cyclic';
                elseif FrameID <= 48127
                    obj.packetDesc = 'RT class 2 frames and RT class 1 unicast';
                else
                    obj.packetDesc = 'RT class 2 frames and RT class 1 multicast';
                end
            elseif FrameID <= 63487
                obj.packetDesc = 'RT class UDP unicast';
            elseif FrameID <= 64511
                obj.packetDesc = 'RT class UDP multicast';
            elseif FrameID <= 64512
                obj.packetDesc = 'Reserved';
            elseif FrameID <= 64513
                obj.packetDesc = 'PROFINET IO Alarm high';
            elseif FrameID <= 65024
                obj.packetDesc = 'Reserved';
            elseif FrameID <= 65025
                obj.packetDesc = 'Alarm Low';
            elseif FrameID <= 65275
                obj.packetDesc = 'Reserved';
            elseif FrameID <= 65279
                obj.packetDesc = 'PN-DCP';
            elseif FrameID <= 65375
                obj.packetDesc = 'PN-PTCP';
            elseif FrameID <= 65407
                obj.packetDesc = 'Reserved';
            elseif FrameID <= 65423
                obj.packetDesc = 'Fragmentation Frame ID';
            elseif FrameID <= 65535
                obj.packetDesc = 'Reserved';
            end
        end
    end
end
