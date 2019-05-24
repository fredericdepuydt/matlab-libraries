%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %%                            UART CLASS                              %%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    Author: Frederic Depuydt                                          %
%  %    Company: KU Leuven                                                %
%  %    Contact: frederic.depuydt@kuleuven.be; f.depuydt@outlook.com      %
%  %    Version: 1.3                                                      %
%  %                                                                      %
%  %    An UART class to analyse PROFIBUS DP packets                      %
%  %    Readable files: ptd (ProfiTrace)                                  %
%  %    Usable with: Scope object                                         %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        FUNCTIONS (static)                 *Object creation*          %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    usage: objUart = uart.function(var1, var2, ...)                   %
%  %                                                                      %
%  %    ptdread(                Importing a ProfiTrace PTD file           %
%  %        file,                   Filename + extension as String        %
%  %        verbose)                Integer to enable verbose mode        %
%  %                                                                      %
%  %    decode(                 Decoding a Scope object                   %
%  %        objScope,               The Scope object to decode            %
%  %        channel,                The channel to be decoded             %
%  %        baudrate,               Baudrate to decode at                 %
%  %        verbose)                Integer to enable verbose mode        %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        FUNCTIONS (non-static)                                        %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    usage: result = objUart.function(var1, var2, ...)                 %
%  %    note: most functions do not alter the original uart object,       %
%  %          but return a new object with the function results           %
%  %                                                                      %
%  %    values(                 Returning the values of a channel         %
%  %        channels)               Array of strings refering to channels %
%  %            returns: matrix of the requested values                   %
%  %                                                                      %
%  %    table(                  Shows a ProfiTrace style table of packets %
%  %        fig)                    Figure handle (optional)              %
%  %            returns: [fig table]    Figure handler and table handler  %
%  %                                                                      %
%  %    plot(                   Plot packets as ProfiTrace styled colors  %
%  %        offset_x,                                                     %
%  %        offset_y,                                                     %
%  %        lineWidth)                                                    %
%  %            returns: nothing                                          %
%  %                                                                      %
%  %    ptdwrite(               Exporting to a ProfiTrace PTD file        %
%  %        file,                   Filename + extension as String        %
%  %        verbose)                Integer to enable verbose mode        %
%  %            returns: nothing                                          %
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

classdef uart < handle
    properties
        id
        time
    end
    properties (Hidden)
        time_end
    end
    properties (Dependent)
        type
    end
    properties
        sa
        da
        fc
    end
    properties (Hidden)
        sap
    end
    properties
        ssap
        dsap
        pdu        
        raw_bytes
        raw_length
    end
    properties (Dependent, Hidden)
        display
    end
    properties (Hidden)
        type_id
    end
    methods
        function obj = uart(num)
            obj.id = num;
            obj.sap = false;
        end
        function value = get.type(obj)
            index = round(log2(obj.type_id)+1);
            values = {'SD1','SD2','SD3','SD4','SC'};
            if (index >= 1 && index <= 5 )
                value = values{index};
            else
                value = 'Illegal';
            end
        end
        function value = get.display(obj)
            value = struct('service','','message','','back_color',[1 1 1],'service_color',[0 0 0],'message_color',[0 0 0]);            
            switch(obj.type_id)
                case {1 2 4}
                    if(bitget(obj.fc,7)) % REQUEST MESSAGE
                        value.service_color = [0 0 0];
                        value.message_color = [0 0 0];
                        switch(mod(obj.fc,16))
                            case 0
                                value.service = 'Time Event';
                            case 3
                                value.service = 'SDA LOW';
                            case 4
                                value.service = 'SDN LOW';
                            case 5
                                value.service = 'SDA HIGH';
                            case 6
                                value.service = 'SDN HIGH';
                            case 7
                                value.service = 'MSRD';
                            case 9
                                value.service = 'FDL Status';
                                value.service_color = [0.3 0.3 0.3];
                            case 12
                                value.service = 'SRD LOW';
                                value.back_color = [1 1 0];
                                if(isempty(obj.ssap) || isempty(obj.dsap)); value.message = 'Data Exchange'; end;
                            case 13
                                value.service = 'SRD HIGH';
                                value.back_color = [1 1 0];
                                if(isempty(obj.ssap) || isempty(obj.dsap)); value.message = 'Data Exchange'; end;
                            case 14
                                value.service = 'Req Ident';
                            case 15
                                value.service = 'LSAP Status';
                             otherwise
                                 value.serivce = 'Reserved';
                        end
                        if(obj.ssap == 62)
                            switch(obj.dsap)
                                case 54
                                    value.message = 'Master-to-Master SAP';  
                                case 55
                                    value.message = 'Set Slave Address';  
                                case 56
                                    value.message = 'Read inputs';  
                                case 57
                                    value.message = 'Read outputs';  
                                case 58
                                    value.message = 'Global Control';  
                                case 59
                                    value.message = 'Get config';  
                                case 60
                                    value.message = 'Get Diagnostics';
                                case 61
                                    value.message = 'Set Parameters';
                                case 62
                                    value.message = 'Check config';                                 
                            end                                              
                        end
                    else % RESPONSE MESSAGE
                        value.service_color = [0 0 1];
                        value.message_color = [0 0 1];
                         switch(mod(obj.fc,16))
                            case 0
                                value.service = 'OK';
                            case 1
                                value.service = 'UE';
                                value.message_color = [1 0 0];
                            case 2
                                value.service = 'RR';
                                value.message_color = [1 0 0];
                            case 3
                                value.service = 'RS';
                                value.message_color = [1 0 0];
                            case 8
                                value.service = 'DL';
                                value.back_color = [0 1 1];
                                if(isempty(obj.ssap) || isempty(obj.dsap)); value.message = 'Data Exchange'; end;
                            case 9
                                value.service = 'NR';
                                value.message_color = [1 0 0];
                            case 10
                                value.service = 'DH';
                                value.back_color = [0 1 1];
                                if(isempty(obj.ssap) || isempty(obj.dsap)); value.message = 'Data Exchange'; end;
                            case 12
                                value.service = 'RDL';
                            case 13
                                value.service = 'RDH';
                             otherwise
                                value.serivce = 'Reserved';
                         end
                         if(obj.dsap == 62)
                            switch(obj.ssap)
                                case 54
                                    value.message = 'Master-to-Master SAP';  
                                case 55
                                    value.message = 'Set Slave Address';  
                                case 56
                                    value.message = 'Read inputs';  
                                case 57
                                    value.message = 'Read outputs';  
                                case 58
                                    value.message = 'Global Control';  
                                case 59
                                    value.message = 'Get config';  
                                case 60
                                    value.message = 'Get Diagnostics';
                                case 61
                                    value.message = 'Set Parameters';
                                case 62
                                    value.message = 'Check config';                                 
                            end                                              
                         end                        
                    end              
                case 8
                    value.service = 'Token pass';
                    value.message = 'Pass token';
                    value.back_color = [1 1 1];
                    value.service_color = [0.3 0.3 0.3];
                    value.message_color = [0 0 0];
                case 16
                    value.service = '';
                    value.message = 'Short acknowledge';
                    value.back_color = [0 1 1];
                    value.service_color = [0 0 0];
                    value.message_color = [0 0 1];
            end
        end
        %% Now filter function captures 3 groups: filter name, filter value
        function result = filter(obj, filterStr)
            expression = '\s*(!|)\s*(da|DA|sa|SA|fc|FC|sd|SD|illegal)\s*(=|<>|)\s*(\d*)\s*(\&\&|and|AND|\|\||or|OR|)';
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
                        case {'da'}
                            findObjFilter = {findObjFilter{:}, 'da', str2double(filterValue)};
                        case {'sa'}
                            findObjFilter = {findObjFilter{:}, 'sa', str2double(filterValue)};
                        case {'fc'}
                            findObjFilter = {findObjFilter{:}, 'fc', str2double(filterValue)};
                        case {'sd'}
                            findObjFilter = {findObjFilter{:}, 'type_id', 2.^(str2double(filterValue)-1)};
                        case {'sc'}
                            findObjFilter = {findObjFilter{:}, 'type_id', 16};
                        case {'illegal'}
                            findObjFilter = {findObjFilter{:}, 'type_id', 0};
                        case {'fcs'}
                            findObjFilter = {findObjFilter{:}, 'type_id', -1};
                        case {'sap'}
                            findObjFilter = {findObjFilter{:}, 'sap', true};
                    end
                    i = i + 1;
                end
                result = findobj(obj,findObjFilter{:})';
            else
                result = {};
            end
        end
        function [fig, table] = table(obj, fig)
            if(~exist('fig','var'));fig = figure('Position',[300 100 1200 800]);end; 
            % create the data
            d = cell.empty(length(obj),0);
            
            colorgen = @(text,color) ['<html><div style="color:rgb(',num2str(color(1)),',',num2str(color(2)),',',num2str(color(3)),');">',text,'</div></html>'];
            bgcolorgen = @(text,color,bgcolor) ['<html><div style="width:100px;height:15px;padding:2px;color:rgb(',num2str(color(1)),',',num2str(color(2)),',',num2str(color(3)),');background-color:rgb(',num2str(bgcolor(1)),',',num2str(bgcolor(2)),',',num2str(bgcolor(3)),');">',text,'</div></html>'];
            
            for i=1:length(obj)
                objDisplay = obj(i).display;
                d{i,1} = obj(i).id;
                d{i,2} = obj(i).time;
                d{i,4} = obj(i).type;
                if(~isempty(obj(i).sa) && ~isempty(obj(i).da))
                    d{i,5} = [num2str(obj(i).sa) ' -> ' num2str(obj(i).da)];
                end
                d{i,6} = bgcolorgen(objDisplay.service,objDisplay.service_color*255,objDisplay.back_color*255);
                d{i,7} = colorgen(objDisplay.message,objDisplay.message_color*255);
                if(~isempty(obj(i).fc));d{i,8}=obj(i).fc; end;
                d{i,9} = '';
                for j=1:length(obj(i).pdu)
                    d{i,9} = [d{i,9} ' ' dec2hex(obj(i).pdu(j))];
                end
            end
            
            % Create the column and row names in cell arrays
            columnname = {'Id','Time','Attention','Frame','Addr','Service','Msgtype','FC','Bytes'};
            columnformat = {'numeric','numeric','char','char','char','char','char','numeric','char'};
            columnwidth = {50,100,100,50,60,100,125,50,500};
            % Create the uitable
            table = uitable(fig,'Data', d,...
                'ColumnName', columnname,...
                'ColumnFormat', columnformat,...
                'ColumnWidth', columnwidth,...
                'RowName',[],...
                'Position',[50 50 fig.Position(3)-100 fig.Position(4)-100],...
                'BackgroundColor',[1 1 1]);
        end
        function plot(obj,offset_x,offset_y, lineWidth)
            %rectangle('Position' , [offset_x+obj(1).time,offset_x+obj(end).time_end],[offset_y,offset_y],'Color','black','LineWidth',lineWidth/10);
            for i=1:length(obj)
                objDisplay = obj(i).display;
                TimeStart = offset_x+obj(i).time;
                TimeEnd = offset_x+obj(i).time_end;
                rectangle ( 'Position' , [TimeStart offset_y-(lineWidth/2) (TimeEnd-TimeStart) lineWidth],...
                        'FaceColor' , objDisplay.back_color,...
                        'EdgeColor', objDisplay.service_color);
            end
        end
        function ptdwrite(obj,file,verbose)
            warn('Experimental feature!');
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if(~exist('file','var'));error('No file');end;
            
            
            number_of_packets = length(obj);
            
            %% Collecting Header Data
            header = zeros(1,1000);
            header(3) = 1;
            header(33:36) = typecast(uint32(number_of_packets),'uint8');
            %header(37) = 5;
            %header(38) = 1;
            %header([41 51 65 79]) = 254;
            header(125:164) = 255;
            header([2,1,897]) = [2,9,5]; %version
            header(901:904) = 255;
            %
            % Version = [num2str(header(2)) '.' num2str(header(1)) '.' num2str(header(897))];
            %
            % Recording_started = datetime(sum(header(69:70).*[2^0 2^8]),header(67),header(66),header(71),header(72),header(73));
            % Recording_stopped = datetime(sum(header(81:82).*[2^0 2^8]),header(79),header(78),header(83),header(84),header(85));
            %
            % comment1 = char(header(165:244));
            % comment2 = char(header(246:325));
            % comment3 = char(header(327:406));
            % comment4 = char(header(408:487));
            % notes = char(header(489:888));
            
            idx = 1001;
            writedata = header;
                        
            for i=1:number_of_packets
                datalength = length(obj(i).pdu);
                blocklength = 35 + datalength;
                data = zeros(1,blocklength);
                data(1:2) = 102;
                data(end-1:end) = 119;
                data(3:4) = typecast(uint16(blocklength-13),'uint8');
                data(end-3:end-2) = typecast(uint16(blocklength-13),'uint8');
                
                data(5) = 1;
                data(6:9) =  typecast(uint32(obj(i).id),'uint8');
                data(10:13) =  typecast(uint32(obj(i).id),'uint8');
                data(14:21) = typecast(uint64(obj(i).time),'uint8');
                data(22) = obj(i).type_id;
                if(sum(obj(i).type_id==[1 2 4 8]))
                    data(24) = obj(i).sa;
                    data(25) = obj(i).da;
                end
                if(sum(obj(i).type_id==[2 4]))
                    if(~isempty(obj(i).ssap) && ~isempty(obj(i).dsap))
                        data(26) = obj(i).ssap;
                        data(27) = obj(i).dsap;
                    else
                        data(26) = 255;
                        data(27) = 255;
                    end
                end
                if(sum(obj(i).type_id==[1 2 4]))
                    data(28) = obj(i).fc;
                end
                if(sum(obj(i).type_id==[2 4]))
                    if(datalength>0)
                        data(29) = datalength;
                        data(32:31+datalength) = obj(i).pdu;
                    end
                end
                writedata(idx:idx+blocklength-1) = data;
                idx = idx + blocklength;
            end
                        
            writedata(5:12) = typecast(uint64(idx-1),'uint8');
            % File openen en schrijven
            fileID = fopen(file, 'w');
            fwrite(fileID,writedata','uint8');
            fclose(fileID);
        end
    end
    methods (Static)
        function obj = ptdread(file,verbose)
            warn('Experimental feature!');
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if(~exist('file','var'));error('No file');end;
            % File openen en uitlezen
            fileID = fopen(file);
            data = fread(fileID)';
            fclose(fileID);
            
            %% Collecting Header Data
            header = data(1:904);
            number_of_packets = sum(header(33:36).*[2^0 2^8 2^16 2^24]);
            baudrates = {9600,19200,38400,187500,500000,1500000,3000000,6000000,12000000};
            baudrate = baudrates{header(37)+1};
            %             
            % Version = [num2str(header(2)) '.' num2str(header(1)) '.' num2str(header(897))];
            %             
            % Recording_started = datetime(sum(header(69:70).*[2^0 2^8]),header(67),header(66),header(71),header(72),header(73));
            % Recording_stopped = datetime(sum(header(81:82).*[2^0 2^8]),header(79),header(78),header(83),header(84),header(85));
            %             
            % comment1 = char(header(165:244));
            % comment2 = char(header(246:325));
            % comment3 = char(header(327:406));
            % comment4 = char(header(408:487));
            % notes = char(header(489:888));
            
            idx = 1001;
            obj = uart.empty(0,number_of_packets);
            
            for i=1:number_of_packets
                blocklength = sum(data(idx+2:idx+3).*[2^0 2^8]) + 13;
                raw = data(idx+2:idx+blocklength-1);
                if(raw(end-1) ~= 119 || raw(end) ~= 119);error('Incorrect end delimiter');end;
                if(sum(raw(end-3:end-2).*[2^0 2^8])+13 ~= blocklength);warn('Incorrect redundant length');end;
                obj(i) = uart(sum(raw(4:7).*[2^0 2^8 2^16 2^24]));
                if(obj(i).id ~= sum(raw(8:11).*[2^0 2^8 2^16 2^24]));warn(['Packet with ID ',num2str(obj(i).id),' has error in redundant ID']);end;
                obj(i).time = sum(raw(12:19).*[2^0 2^8 2^16 2^24 2^32 2^40 2^48 2^56])/baudrate;
                obj(i).type_id = raw(20);
                switch(obj(i).type_id)
                    case 1
                        obj(i).sa = raw(22);
                        obj(i).da = raw(23);
                        obj(i).fc = raw(26);
                        obj(i).time_end = obj(i).time + 6*11/baudrate;
                    case 2
                        obj(i).sa = raw(22);
                        obj(i).da = raw(23);
                        if(raw(24) ~= 255 || raw(25) ~= 255)
                            obj(i).ssap = raw(24);
                            obj(i).dsap = raw(25);
                        end
                        obj(i).fc = raw(26);
                        if(raw(27)>0);obj(i).pdu = raw(30:29+raw(27));end;
                        obj(i).time_end = obj(i).time + (9+raw(27))*11/baudrate;
                    case 4
                        obj(i).sa = raw(22);
                        obj(i).da = raw(23);
                        if(raw(24) ~= 255 || raw(25) ~= 255)
                            obj(i).ssap = raw(24);
                            obj(i).dsap = raw(25);
                        end
                        obj(i).fc = raw(26);                     
                        if(raw(27)>0);obj(i).pdu = raw(30:29+raw(27));end;                        
                        obj(i).time_end = obj(i).time + 14*11/baudrate;
                    case 8
                        obj(i).sa = raw(22);
                        obj(i).da = raw(23);                                          
                        obj(i).time_end = obj(i).time + 3*11/baudrate;
                    case 16        
                        obj(i).time_end = obj(i).time + 11/baudrate;
                end                
                idx = idx + blocklength;
            end                      
        end
        function [P,error] = decode(objScope,channel,BAUDRATE,verbose)
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if(~exist('channel','var'));channel='CH1';end;
            if(~exist('BAUDRATE','var'));BAUDRATE=1500000;end;
            
            if(verbose);disp('Decoding UART');end;
            if(verbose);disp('   1) Filtering Scope Signal');end;
            PERIOD = 1/BAUDRATE;
            
            X = objScope.time;
            Y = objScope.values(channel);
            if(BAUDRATE>160000)
                Y = objScope.bandstop(Y,[40,60;140,160;2*BAUDRATE,1e99],verbose-(verbose>0));
            elseif(BAUDRATE>60000)
                Y = objScope.bandstop(Y,[40,60;2*BAUDRATE,1e99],verbose-(verbose>0));
            else
                Y = objScope.bandstop(Y,[2*BAUDRATE,1e99],verbose-(verbose>0));
            end
            
            if(verbose);disp('   2) Converting Scope to bitstream');end;
                        
            %% SETTING PLOT PARAMETERS
            if(verbose-(verbose>0))
                plotMin =  1;
                plotMax =  10000;
                Xmin = X(plotMin);
                Xmax = X(plotMax);
                Ymin = -10;
                Ymax = +10;
            end
            %% PLOTTING GRAPH 1
            if(verbose-(verbose>0))
                figure;
                subplot(4,1,1);
                XT = objScope.time;
                YT = objScope.values(channel);
                hold on;
                plot(XT(Xmin<XT & XT<Xmax),YT(Xmin<XT & XT<Xmax), 'color', [0.5 0.5 0.5]);
                plot(X(plotMin:plotMax),Y(plotMin:plotMax),'r');
                axis([Xmin,Xmax,Ymin,Ymax]);
                hold off;
            end
            Y = Y-min(Y);
            Y = Y/max(Y);
            %% PLOTTING GRAPH 2-A
            if(verbose-(verbose>0))
                subplot(4,1,2);
                hold on;
                plot(X(plotMin:plotMax),Y(plotMin:plotMax),'r');
            end            
            %% CALCULATING ONE AND ZERO AREA'S
            Y = conv(Y,ones(1,floor(PERIOD/objScope.sample_interval*0.95)+1),'same');
            YT = Y/max(Y);
            %Y = (Y/max(Y))>(sum(Y/max(Y))/length(Y));
            Y = (Y/max(Y))>0.575;
            %% PLOTTING GRAPH 2-B
            if(verbose-(verbose>0))
                plot(X(plotMin:plotMax),YT(plotMin:plotMax), 'color', [0.5 0.5 0.5]);
                plot(X(plotMin:plotMax),Y(plotMin:plotMax),'b');
                axis([Xmin,Xmax,-0.25,1.25]);
                hold off;
            end
            %% DETERMINING RELIABLE BIT SAMPLES
            dY = [diff(Y),0];
            sX = X+objScope.sample_interval/2;
            sX = sX(dY(1:end-1)~=0)+PERIOD/2;
            %% DETERMINING UNRELIABLE BIT SAMPLES BY INTERPOLATION
            dsX = diff(sX);
            j = 1;
            Vx = zeros(1,round((max(sX)-min(sX))/PERIOD+1));
            for i = 1:1:length(sX)-1
                K = round(dsX(i)/PERIOD);
                F = dsX(i)/K;
                Vx(j:j+K) = sX(i)+(0:F:K*F);
                j = j+K;
            end
            if length(Vx)>j+K; Vx(j+K+1:end) = []; end;
            clear j K F sX dsX;
            %% GETTING BIT VALUE FOR ALL DETERMINED SAMPLES
            Vy = zeros(1,length(Vx));
            j = find(X>Vx(1)-PERIOD/2,1);
            Interval = PERIOD/4;                  
            for i=1:length(Vx)
                k = 0;
                if(Vx(i)>X(end));Vy(i)=0;break;end;
                while X(j) < Vx(i) - Interval; j = j + 1; end;
                while X(j) < Vx(i) + Interval
                    Vy(i) = Vy(i) + Y(j);
                    k = k + 1;
                    j = j + 1;
                end
                Vy(i) = Vy(i)/k;
            end
            clear X Y k i j;                        
             %% PLOTTING GRAPH 3
            if(verbose-(verbose>0))
                subplot(4,1,3);
                hold on;
                Zeros = length(Vy(Vy==0))/length(Vy);
                Others = length(Vy(Vy>0 & Vy<1));
                Ones = length(Vy(Vy==1))/length(Vy);
                text(0.05,0.50,['Zeros: ' num2str(100*Zeros) '%']);
                text(0.05,0.75,['Other: ' num2str(Others)]);
                text(0.05,1.00,['Ones:  ' num2str(100*Ones) '%']);
                plt((1:length(Vy))/length(Vy),sort(Vy),'downsample',100000,'b');
                if(Others>0); plt((1:Others)/Others,sort(Vy(Vy>0 & Vy<1)),'r'); end;
                axis([0,1,-0.25,1.25]);
                hold off;
                clear Zeros Others Ones;
            end            
            %% DISCRETIZE BIT VALUES
            Vy = (Vy > 0.50)*1;
            %% PLOTTING GRAPH 4-A
            if(verbose-(verbose>0))
                subplot(4,1,4);
                hold on;
                X = objScope.time;
                Y = objScope.values(channel);
                Y = Y-min(Y);
                Y = Y/max(Y);
                plot(X(plotMin:plotMax),Y(plotMin:plotMax),'r');
                stem(Vx(Xmax>Vx & Vx>Xmin),Vy(Xmax>Vx & Vx>Xmin), 'color', [0.5 0.5 0.5]);
                clear X Y;
                hold off;
            end
            %% REMOVING IDLE BITS
            CVy = find(conv(Vy,ones(1,11),'same')==11)+5;
            %dVy = abs(Vy+5);
            Vy(1:CVy(1)) = 0.5;
            Vy(CVy) = 0.5;
            Vy(CVy(end):end) = 0.5;
            
            r_edge = find(diff(Vy~=0.5)>0)+1;
            f_edge = find(diff(Vy~=0.5)<0);
            
            r_edge = r_edge+floor((f_edge-r_edge)/11)*11;
            packets = length(r_edge);
            for i = 1:packets
                Vy(r_edge(i):f_edge(i)) = 0.5;
            end
                        
            %% PLOTTING GRAPH 4-B
            if(verbose-(verbose>0))
                hold on;
                stem(Vx(Xmax>Vx & Vx>Xmin),Vy(Xmax>Vx & Vx>Xmin),'b');
                axis([Xmin,Xmax,-0.25,1.25]);
                hold off;
                clear X Y;
            end
                     
            if(verbose);disp('   3) Decoding bitstream to UART Byte Packets');end;
            Vy = Vy*2-1;
            P = uart.empty(0,packets);
            k=1;
            tic
            pos_edges = find(diff(abs(Vy))>0)+1;
            neg_edges = find(diff(abs(Vy))<0);
            
            if(pos_edges(1)>neg_edges(1));neg_edges = neg_edges(2:end);end;
            if(pos_edges(end)>neg_edges(end));pos_edges = pos_edges(1:end-1);end;
            for i = 1:length(pos_edges)
                P(k) = uart(k);
                P(k).time = Vx(pos_edges(i))-0.5/BAUDRATE;
                bits = Vy(pos_edges(i):neg_edges(i))>0;
                if(length(bits)>=11)
                    for j=1:floor(length(bits)/11)
                        if(bits(j*11-10)==0 && bits(j*11)==1 && mod(sum(bits(j*11-9:j*11-2)),2)==bits(j*11-1))
                            P(k).raw_bytes(j) = sum(bits(j*11-9:j*11-2).*(2.^(0:7)));
                        else
                            P(k).raw_bytes(j) = -1;
                        end
                    end
                else
                    P(k).raw_bytes(1) = -1;
                end
                k=k+1;
            end
            
            if(verbose);disp('   4) Decoding UART Bytes Packets to PROFIBUS Packets');end;
            error.illegals = 0;
            error.fcs = 0;
            i = 1;
            while i<=length(P)
                P(i).type_id = 0;
                P(i).raw_length = 0;
                
                switch(P(i).raw_bytes(1))
                    case 16 %10
                        if(length(P(i).raw_bytes) >= 6)
                            if(P(i).raw_bytes(6)==22)
                                P(i).type_id = 1';
                                P(i).raw_length = 6;
                                P(i).da = mod(P(i).raw_bytes(2),128);
                                P(i).sa = mod(P(i).raw_bytes(3),128);
                                P(i).fc = P(i).raw_bytes(4);
                                FCS = 0;
                                for j=2:4
                                    FCS = FCS + P(i).raw_bytes(j);
                                end
                                if(mod(FCS,256) ~= P(i).raw_bytes(5));P(i).type_id = -1;end;
                            end
                        end
                    case 104 %68
                        if(length(P(i).raw_bytes)>=9)
                            if(length(P(i).raw_bytes) >= 6 + P(i).raw_bytes(2))
                                if(P(i).raw_bytes(6 + P(i).raw_bytes(2))==22 && ...
                                        P(i).raw_bytes(2)==P(i).raw_bytes(3) && ...
                                        P(i).raw_bytes(1)==P(i).raw_bytes(4))
                                    P(i).type_id = 2;
                                    P(i).raw_length = 6 + P(i).raw_bytes(2);
                                    P(i).da = mod(P(i).raw_bytes(5),128);
                                    P(i).sa = mod(P(i).raw_bytes(6),128);
                                    if(bitget(P(i).raw_bytes(5),8) && bitget(P(i).raw_bytes(6),8))
                                        P(i).sap = true;
                                        P(i).dsap = P(i).raw_bytes(8);
                                        P(i).ssap = P(i).raw_bytes(9);
                                        if(P(i).raw_length>11)
                                            P(i).pdu = P(i).raw_bytes(10:P(i).raw_length-2);
                                        end
                                    else
                                        P(i).pdu = P(i).raw_bytes(8:P(i).raw_length-2);
                                    end
                                    P(i).fc = P(i).raw_bytes(7);
                                    FCS = 0;
                                    for j=5:P(i).raw_length-2
                                        FCS = FCS + P(i).raw_bytes(j);
                                    end
                                    if(mod(FCS,256) ~= P(i).raw_bytes(P(i).raw_length-1));P(i).type_id = -1;end;
                                end
                            end
                        end
                    case 162 % A2
                        if(length(P(i).raw_bytes) >= 14)
                            if(P(i).raw_bytes(14)==22)
                                P(i).type_id = 4;
                                P(i).raw_length = 14;
                                P(i).da = mod(P(i).raw_bytes(2),128);
                                P(i).sa = mod(P(i).raw_bytes(3),128);
                                P(i).fc = P(i).raw_bytes(4);
                                FCS = 0;
                                for j=2:12
                                    FCS = FCS + P(i).raw_bytes(j);
                                end
                                if(mod(FCS,256) ~= P(i).raw_bytes(13));P(i).type_id = -1;end;
                            end
                        end
                    case 220 % DC
                        if(length(P(i).raw_bytes) >= 3)
                            P(i).type_id = 8;
                            P(i).raw_length = 3;
                            P(i).da = P(i).raw_bytes(2);
                            P(i).sa = P(i).raw_bytes(3);
                        end
                    case 229 % E5
                        if(length(P(i).raw_bytes) >= 1)
                            P(i).type_id = 16;
                            P(i).raw_length = 1;
                        end
                end                
                P(i).time_end = P(i).time + PERIOD*11*P(i).raw_length;
                if(P(i).type_id == 0)
                    error.illegals = error.illegals + 1;
                elseif(P(i).type_id == -1)
                    error.fcs = error.fcs + 1;
                else                
                    if(P(i).raw_length<length(P(i).raw_bytes) && P(i).raw_bytes(P(i).raw_length+1) ~= -1)
                        tmpP = uart.empty(0,length(P)+1);
                        tmpP(1:i) = P(1:i);
                        tmpP(i+1) = uart(i+1);      
                        tmpP(i+1).raw_bytes = P(i).raw_bytes(P(i).raw_length+1:end);
                        tmpP(i+1).time = tmpP(i).time_end;
                        tmpP(i+2:length(P)+1) = P(i+1:end);
                        for j = i+2:length(P)+1
                           tmpP(j).id = tmpP(j).id + 1;
                        end
                        P=tmpP;
                    end
                end                
                i=i+1;
            end
            if(verbose)
                disp('   5) Analyzing Packets');
                disp(['        Packets:   ' num2str(length(P))]);
                disp(['        Illegals:   ' num2str(error.illegals)]);
                disp(['        FCS Errors: ' num2str(error.fcs)]);
                disp(['        Succes rate:   ' num2str(round(100*(length(P)-error.illegals-error.fcs)/length(P),2)) '%']);                
            end
        end
    end
end