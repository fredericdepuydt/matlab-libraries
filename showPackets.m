function varargout = showPackets(varargin)        
%% 
% This function displays graph of measurements taken
%
% showPackets(ethObjArr)
%
% ethObjArr is a mandatory field. It is a cell array of eth objects.
%
% showPackets(__, 'PropName', PropValue)
%
% Properties:
%
% 'packetNumRange', measurementNum, time_vector - Align axes by user defined packet numbers
% 
% 'time', [leftTimeBorder, rightTimeBorder] - Show defined timerange(it counts from the earliest measerument)
%
% 'colors', colorVector - Set tick colors, colorVector should have the same cell size as passed ethObjArr
%
%
% Examples:
%
% showPackets({etharr1,etharr2},'time',[8.05,8.22]) 
% showPackets({etharr1,etharr2},'time',[8.05,8.22], 'colors', {[0 1 1], [0 1 0]})     
    fig = figure('Tag','mainWindow','HitTest','Off');
    % Handling Window Button Down to hide a hovering packet description label if any exists
    fig.WindowButtonDownFcn = @removePacketDescLabel;
    visibleTimeMax  = 0;
    inputColorArr   = {};
    displayGUI (size(varargin{1},2));           
    displayPlot (varargin{:}); 
    ax = gca();
    initialScale = ax.XLim;
    % Variables for storing temporary timechanges
    savedShuffledPackets    = [];    
    savedShuffleArr         = [];
    hdlZoom = zoom;
    hdlZoom.ActionPostCallback = @resizeCallbackFcn;
    jLabel = '';
    varargout{1} = fig;
    
    function [macHexFormatted] = convertMACArr (macVector)
    % Helper function for converting MAC vector to the default string view    
       macHex = dec2hex(macVector,2)';
       macHex = macHex(:)';
       macHexFormatted = regexprep(macHex, '.{2}(?=.{2})', ['$0' ':']);
    end
    
    function removePacketDescLabel (src, event)
    % This function removes hover packet description
        if ~isempty(jLabel)

            if isa(jLabel,'javahandle_withcallbacks.javax.swing.JLabel')
                delete(jLabel);
            end

        end 

    end

    function packetClick (src,event)
    % Handler for packet click event        
        mainAxes        = findobj('Tag','mainAxes');
        mainAxesPos     = getpixelposition(mainAxes);       
        currentPacket   = findobj(varargin{1}{src.UserData(1)},'packetNum',src.UserData(2));
        mainAxesXLim    = xlim(mainAxes);
        axesPosPixelX   = ((event.IntersectionPoint(1)-mainAxesXLim(1))/diff(xlim(mainAxes)))*mainAxesPos(3);
        axesPosPixelY   = (event.IntersectionPoint(2)/diff(ylim(mainAxes)))*mainAxesPos(4);

        if ~isempty(jLabel)

            if isa(jLabel,'javahandle_withcallbacks.javax.swing.JLabel')
                delete(jLabel);
            end

        end    

        jLabel  = javacomponent( 'javax.swing.JLabel', [mainAxesPos(1) + axesPosPixelX mainAxesPos(2) + axesPosPixelY 250 140] );
        msg     = sprintf('<html><BODY bgcolor="#feffcd"><b>packetNum:</b> %d<br><b>packetLen:</b> %d<br><b>time:</b> %d<br><b>srcMac:</b> %s<br><b>dstMac:</b> %s<br><b>packetDesc:</b> %s</body></html>',...
                    currentPacket.packetNum,currentPacket.packetLen,currentPacket.time, convertMACArr(currentPacket.srcMac),...
                    convertMACArr(currentPacket.dstMac),currentPacket.packetDesc);
        set(handle(jLabel),'text',msg);
        jLabel.setBackground(java.awt.Color(254/255,1,205/255));
        jLabel.setName('packetDescLabel');
        jLabel.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR))
        set( jLabel, 'MouseClickedCallback', @labelClick );       
    end

    function labelClick (src,event)
    % Label Click Handler
       delete(src);
    end


    function colorAxes (userAxes, userColorsArr)   
    % The coloring function below creates one axes object(layer) per one eth object
    % There is not any property to set Tick Color in more simple way
        overlayAxes = findobj('Type','axes','-and','UserData','overlayAxe');

        if ( ~isempty(overlayAxes) )
            % Delete non-relevant axes if any
            delete(overlayAxes);
        end               

        if ~isempty(userColorsArr)
            mainFig     = userAxes.Parent;
            graphNum    = length(userAxes.YTick);
            userAxes.TickLength = [0.013 0];
            YTicksLabels        = flip(userAxes.YTickLabel)';
            
            for i = 1 : graphNum
               % Creating overlay axes to color YTicks
               YAxe         = graphNum + 1 - i;    
               clearAxes    = axes('Parent',mainFig,'Position',[.05 .17 .9 .8],'UserData','overlayAxe','HitTest','Off');
               clearAxes.XLim   = xlim(userAxes);
               clearAxes.YLim   = ylim(userAxes);
               clearAxes.Color  = 'none';
               clearAxes.XTick  = [];
               clearAxes.YTick  = YAxe;
               clearAxes.YTickLabel = YTicksLabels{i};  
               clearAxes.TickLength = [0 0];               

               if length(userColorsArr) ~= 1
                   clearAxes.YColor = userColorsArr{i};  
               else
                   clearAxes.YColor = userColorsArr{1};  
               end
               
               clearAxes.Color = 'none';
               linkaxes([userAxes clearAxes]);
            end    
 
            % Creating overlay axes for saving original YTicks
            clearAxes = axes('Parent',fig,'Position',[.05 .17 .9 .8],'Color','None','UserData','hiddenYTick','Visible','off','HitTest','Off');
            clearAxes.XLim  = xlim(userAxes);
            clearAxes.YLim  = ylim(userAxes);
            clearAxes.YTick = userAxes.YTick;    
            clearAxes.YTickLabel = userAxes.YTickLabel;   
            linkaxes([userAxes clearAxes]);                  
            uistack(userAxes,'top');
            userAxes.YTickLabel = [];
            userAxes.YTick      = [];                
            fig.CurrentAxes     = userAxes;                
        end
    end
    
    function btnApplySync_callback (hObject, eventdata)
    % Saving synchronization time array to GUI's inner variables    
        if ~exist('savedShuffleArr','var')
            warndlg('Measured object are same as before.');
        else
            hMainGui        = getappdata(0, 'hMainGui');
            tblFilteredList = findall(hMainGui, 'Tag', 'tblFilteredList');
            % Display a new plot to a user
            tb  = findobj(fig, 'Tag', 'fileTable');
            btn = findobj(fig, 'Tag', 'btnReplot');
            btnReplot_callback(btn);
            ethArr = varargin{1};       
                        
            for i = 1 : length(savedShuffleArr)
                idx = find(strcmp([tblFilteredList.Data(:,1)], tb.Data{i,1}));
                
                if ~isempty(tblFilteredList.Data{i,2})
                    tblFilteredList.Data{i,2} = tblFilteredList.Data{i,2} + savedShuffleArr(i);
                else
                    tblFilteredList.Data{i,2} = savedShuffleArr(i);
                end
                
                if (savedShuffleArr(i)~=0)
                    % Change time of all eth objects of current eth array                    
                    ethObj = ethArr{1,i};
                    ethObj.shuffleTime(savedShuffleArr(i));
                    ethArr{1,i} = ethObj;
                end

            end
            varargin{1} = ethArr;
            % Clear shuffled time arrar
            tb.Data(:,2) = num2cell(zeros(size(tb.Data,1),1));   
            tb.Data(:,3) = num2cell(logical(zeros(size(tb.Data,1),1)));
            savedShuffleArr      = [];
            savedShuffledPackets = [];            
        end

    end

    function sync_method_callback (hObject, eventdata)    
    % Set tables' default values
        tb = findobj(fig, 'Tag', 'fileTable');
        tb.Data(:,2) = num2cell(zeros(size(tb.Data,1),1));

        if hObject.Value == 1

            if ~isempty(savedShuffledPackets)
                tb.Data(:,2) = savedShuffledPackets;
            end

            tb.ColumnName{2}  = 'Packet Number';       
            tb.ColumnEditable = logical([0 1 1]);
        elseif hObject.Value == 2

            if ~isempty(savedShuffleArr)
                tb.Data(:,2) = mat2cell(savedShuffleArr,ones(1,length(savedShuffleArr)),1);
            end

            tb.ColumnName{2}  = 'Time diff';
            tb.ColumnEditable = logical([0 1 0]);
        end

    end    

    function pm_disp_options (hObject, eventdata)
    % Change some label values when user choose another sync method        
        lblMin = findobj(fig, 'Tag', 'lblMin');
        lblMax = findobj(fig, 'Tag', 'lblMax');
        txt1 = findobj(fig,'Tag','txtLeftBorder');
        txt2 = findobj(fig,'Tag','txtRightBorder');
        txt1.String = '';
        txt2.String = '';

        if hObject.Value > 1
            lblMin.String = 'packetMin';
            lblMin.Position = [560 20 80 20];            
            lblMax.String = 'packetMax';            
            lblMax.Position = [660 20 80 20];                 
        else
            lblMin.String = 'timeMin';
            lblMin.Position = [570 20 80 20];
            lblMax.String = 'timeMax';    
            lblMax.Position = [670 20 80 20];            
        end

    end


    function btnReplot_callback (hObject, eventdata)              
    % Function for replotting a graph with new timerange or new sync option        
        hObject.Enable = 'on';
        % Get chosen sync method
        pmSyncMethod = findobj(fig,'Tag', 'pmSyncMethod');
        % Get display options value
        pmDispOptions = findobj(fig,'Tag','pmDispOptions');
        % Get text fields values
        txt1 = findobj(fig,'Tag','txtLeftBorder');
        txt2 = findobj(fig,'Tag','txtRightBorder');
        fileTable   = findobj(fig,'Tag','fileTable');   
        leftBorder  = str2num(txt1.String);
        rightBorder = str2num(txt2.String);        
        yTickLabelsElem = findobj('Tag','mainAxes');
        yTickLabels     = flip(yTickLabelsElem.YTickLabel');        
        
        if isempty(yTickLabels)
            yTickLabelsElem = findobj('Type','axes','-and','UserData','hiddenYTick');         
            yTickLabels = flip(yTickLabelsElem.YTickLabel');            
        end
        
        if pmDispOptions.Value == 1

            if isempty(leftBorder)
                leftBorder = 0;
            end
            
            if isempty(rightBorder)
                rightBorder = 0.1;
            end
                        
            displayPlot (varargin{1}, 'time', [leftBorder, rightBorder], 'names', yTickLabels, 'colors', inputColorArr);
        else

            if isempty(leftBorder) || isempty(rightBorder)
                warndlg('Input packet number range.');
            else
                ethIdx = pmDispOptions.Value-1;                
                displayPlot (varargin{1}, 'packetNumRange', ethIdx, [leftBorder, rightBorder], 'names', yTickLabels, 'colors', inputColorArr);                           
            end

        end
        
        % Check if table contains all necessary sync data            
        % Look to Children property of figure object, move them
        % depending on position of the object
        if  pmSyncMethod.Value == 1             
            syncPacketNumArr = fileTable.Data(:,2);                                 
            lockStateArr = [];
            shuffleArr   = [];     

            for i = 1 : length(syncPacketNumArr)
           
                if ~isempty(syncPacketNumArr{i,1})

                    if isempty(fileTable.Data{i,3}) || fileTable.Data{i,3}==0
                        lockState = 0;
                    else
                        lockState = 1;
                    end

                    if ~exist('ethArr','var')
                        ethArr = varargin{1};                                            
                    end

                    % Check if object has entered packet number
                    packetNum = syncPacketNumArr{i,1};
                    ethObj = ethArr{1,i};
                    ethObj = findobj(ethObj, 'packetNum', packetNum);

                    if isempty(ethObj) 

                        if packetNum == 0
                           shuffleArr = [shuffleArr(:); 0];
                           lockStateArr = [lockStateArr(:); 0];
                        else
                            msg = sprintf('You entered non-existent packet number: %d', packetNum);
                            warndlg(msg);
                            break;
                        end

                    else
                        % get time and lock state
                        ethObj.time

                        if exist('lockState','var')

                            if lockState == 1 && any(lockStateArr)
                                movePlotRun = false;
                            else
                                movePlotRun = true;
                                lockStateArr = [lockStateArr(:); lockState];    
                                shuffleArr = [shuffleArr(:); ethObj.time];                                
                            end

                        else
                            lockStateArr = [lockStateArr(:); lockState];
                            shuffleArr = [shuffleArr(:); ethObj.time];
                        end

                    end
                
                else
                    
                    shuffleArr = [shuffleArr(:); 0];
                    lockStateArr = [lockStateArr(:); 0];
                end

            end 

            if exist('movePlotRun','var') && i == length(syncPacketNumArr) && movePlotRun
                % Loop ended successfully
                % Change shuffleArr to appropriate values                
                objLockedIdx = find(lockStateArr == 1);
                shuffleArr1 = zeros([1,length(shuffleArr)]);
                if ~isempty(objLockedIdx)
                    timeLocked = shuffleArr(objLockedIdx);
                    for i = 1 : length(shuffleArr)

                        if shuffleArr(i) ~= 0 && shuffleArr(i) > 30

                            if lockStateArr(i) == 1
                                shuffleArr1(i) = 0;
                            else
                                shuffleArr1(i) = timeLocked - shuffleArr(i);                            
                            end
                        
                        elseif shuffleArr(i) <= 30
                            % It is a scope measurement
                            if lockStateArr(i) == 1
                                shuffleArr1(i) = 0;
                            else
                            %  shuffleArr1(i) = timeLocked - shuffleArr(i);                            
%                                 shuffleArr1(i) = timeLocked - ethArr{objLockedIdx}(1).time - shuffleArr(i);
                                shuffleArr1(i) = timeLocked - shuffleArr(i);
                            end       
                            
                        end

                    end                
                    movePlot(shuffleArr1);
                    savedShuffledPackets = syncPacketNumArr;
                end

            end

        elseif pmSyncMethod.Value == 2 && ~any(find(cellfun('isempty',fileTable.Data(:,2))))
            shuffleArr = cell2mat(fileTable.Data(:,2));               
            movePlot(shuffleArr);      
            savedShuffledPackets = [];          
        end
        ax = gca();
        initialScale = ax.XLim;   
    end

    function movePlot (shuffleArr)        
    % This function moves inner axes objects basing on input variable shuffleArr
    % Function should apply a numeric vector with the exact size as total measurements        
        LINE_WIDTH = 0.02;
        % Select necessary figure handles
        axes = gca();        
        XAxes             = findobj(axes.Children(),'UserData','XAxe');
        packetNumLabels   = findobj(axes.Children(), 'Type', 'text', '-not', 'Tag', 'packetCount');
        packetNumPosArr   = reshape([packetNumLabels.Position],3,[]);
        packetTicks       = findobj(axes.Children(), 'Type','rectangle','-not','UserData','XAxe');        
        packetTicksPosArr = reshape([packetTicks.Position],4,[]);

        for i = length(XAxes) : -1: 1
            shuffleValue = shuffleArr(i);                    
            % Current Axes Elements Indexes are defined below
            packetLabelPosIdx = find(packetNumPosArr(2,:)== length(XAxes) - i + 1 + 4.5*LINE_WIDTH);                    
            packetTicksOnThisAxeIdx = find(packetTicksPosArr(2,:)== length(XAxes) - i + 1 - 3.5*LINE_WIDTH);
            % Change Position of every line if any
            if ~isempty(shuffleValue) && shuffleValue ~= 0

                for j = 1 : size(packetLabelPosIdx,2)
                    packetNumLabels(packetLabelPosIdx(j)).Position = packetNumLabels(packetLabelPosIdx(j)).Position + [shuffleValue 0 0];
                    packetTicks(packetTicksOnThisAxeIdx(j)).Position = packetTicks(packetTicksOnThisAxeIdx(j)).Position + [shuffleValue 0 0 0];
                end

            end

        end    

        % Align new axes positions
        packetTicks = findobj(axes.Children(), 'Type','rectangle','-not','UserData','XAxe');        
        packetTicksPosArr = reshape([packetTicks.Position],4,[]);        
        wholeLength = max(packetTicksPosArr(1,:)) - min(packetTicksPosArr(1,:));
        leftBorder  = min(packetTicksPosArr(1,:)) - 0.05*wholeLength;
        rightBorder = max(packetTicksPosArr(1,:)) + 0.05*wholeLength;

        for i = 1 : length(XAxes)
            XAxes(i).Position = [leftBorder i-(LINE_WIDTH/2) 1.1*wholeLength LINE_WIDTH];                    
        end

        axes = gca();
        axes.XLim = [leftBorder rightBorder];
        % Save shuffle values
        savedShuffleArr = shuffleArr;
    end

    function displayGUI (graphNum)
    % This function displays GUI of plot        
        pmString        = cell (1,graphNum+1);
        pmString{1,1}   = 'time';
        for i = 1 : graphNum
            pmString{1,i+1} = strcat('M',num2str(i));
        end
        % Obtaining screen size to display a figure window
        set (0, 'Units', 'pixels');
        screenSize      = get(0, 'screensize');
        screenWidth     = screenSize(3);
        screenHeight    = screenSize(4);
        fig.Position    = [screenWidth*0.05 screenHeight*0.05 screenWidth*0.9 screenHeight*0.85];
        fig.Name = 'Measurement comparison';
        fig.NumberTitle = 'Off';
        dateMsg = sprintf('01-Aug-2016\n24:01:46');
        tdate = uicontrol(fig,'Style','text',...
                        'String',dateMsg,...
                        'HorizontalAlignment', 'left',...
                        'Position',[50 105 70 40],...
                        'Tag', 'measuredAtTimeLabel');        
        t = uicontrol(fig,'Style','text',...
                        'String','Synchronization method:',...
                        'HorizontalAlignment', 'left',...
                        'Position',[50 80 130 20]);
        pm = uicontrol(fig,'Style','popupmenu',...
                        'String',{'packetNum','Time diff.'},...
                        'Callback',@sync_method_callback,...
                        'Value',1,'Position',[50 60 130 20],...
                        'Tag', 'pmSyncMethod');
        t = uicontrol(fig,'Style','text',...
                        'String','Enter values to the table on the right.',...
                        'HorizontalAlignment', 'left',...
                        'Position',[50 25 130 30]);
        tbData = cell(graphNum,3);
        temp = pmString';
        tbData(:,1) = temp(2:end);
        tb = uitable(fig,'Data',tbData,...
                     'Position',[200 5 342 100],...
                     'RowName', [],...
                     'ColumnName', {'Measurement', 'Packet Number', 'Ref.'},...
                     'ColumnFormat', {'char', 'numeric', 'logical'},...
                     'ColumnWidth', {170 100 65},...
                     'ColumnEditable', [false true true],...
                     'Tag', 'fileTable');  
        t1 = uicontrol(fig,'Style','text',...
                        'String','Display options:',...
                        'HorizontalAlignment', 'left',...
                        'Position',[580 80 190 20]);        
        pm1 = uicontrol(fig,'Style','popupmenu',...
                        'String',pmString,...
                        'Callback', @pm_disp_options,...
                        'Value',1,'Position',[580 60 190 20],...
                        'Tag', 'pmDispOptions');         
        t2 = uicontrol(fig,'Style','text',...
                        'String','timeMin',...
                        'HorizontalAlignment', 'left',...
                        'Position',[570 20 80 20],...
                        'Tag', 'lblMin');      
        txtbox1 = uicontrol(fig,'Style','edit',...
                        'String','',...
                        'Position',[610 23 50 20],...
                        'Tag', 'txtLeftBorder');            
        t3 = uicontrol(fig,'Style','text',...
                        'String','timeMax',...
                        'HorizontalAlignment', 'left',...
                        'Position',[670 20 80 20],...
                        'Tag', 'lblMax'); 
        timeLimiter =  uicontrol(fig,'Style','text',...
                        'String','< counting..',...
                        'HorizontalAlignment', 'left',...
                        'Position',[670 0 80 20],...
                        'Tag', 'timeLimiter');                             
        txtbox2 = uicontrol(fig,'Style','edit',...
                        'String','',...
                        'Position',[715 23 50 20],...
                        'Tag','txtRightBorder');     
        btnReplot = uicontrol(fig,'Style','togglebutton',...
                        'String','Replot graph',...
                        'Value',0,'Position',[780 23 120 60],...
                        'Callback',@btnReplot_callback,...
                        'Tag', 'btnReplot');       
        bg = uibuttongroup(fig,'Title','Coloring options',...          
            'Units', 'Pixels', ...
            'Position',[920 23 150 100], ...
            'Tag', 'ColoringOptionGroup', ...
            'SelectionChangedFcn',@(bg,event) colorGroupSelection(bg,event));           
        r1 = uicontrol(bg,'Parent', bg,...
                          'Enable','off',...
                          'Style','radiobutton',...
                          'HandleVisibility','on',...                            
                          'String','default mode',...
                          'Units', 'Pixels', ...
                          'Position',[15 50 120 15],...                          
                          'Tag','defColoringRadioBtn');
        r2 = uicontrol(bg,'Style','radiobutton',...
                          'Enable','off',...
                          'Parent', bg,...
                          'String','user defined colors',...
                          'Units', 'Pixels', ...
                          'Position',[15 20 120 15],...
                          'HandleVisibility','on',...
                          'Tag','userColoringRadioBtn');  
        btnReplot = uicontrol(fig,'Style','togglebutton',...
                        'String','Apply synchronization',...
                        'Value',0,'Position',[1100 23 120 60],...
                        'Callback',@btnApplySync_callback,...
                        'Tag', 'btnApplySync');       
        bg.Visible = 'on';
        ax = axes('Parent',fig,'Position',[.05 .17 .9 .8],'Tag','mainAxes','NextPlot','Replacechildren');  
    end

    function colorGroupSelection(bg, event)
    % Coloring group click handler
        mainAxes = findobj('Tag','mainAxes');     

        if ~strcmp(bg.SelectedObject.String,'default mode')
            colorAxes(mainAxes, inputColorArr);
        else
            colorAxes(mainAxes, {[0 0 0]});
        end

    end


    function displayPlot (varargin)        
    % Plot display function                
        tic;    
        mainAxes = findobj('Tag','mainAxes');
        cla(mainAxes);   
        % Checking input arguments   
        if isempty(varargin)
            error('You have not input any arguments');
        end

        if iscell(varargin{1})
            for i = 1 : size(varargin{1},1)

                if ~isa(varargin{1}{i},'eth')
                    error('First argument should be an array of eth class objects.')
                end

            end
        else
            error('First argument should be an array of eth class objects.')
        end
        ethArr   = varargin{1};
        graphNum = size(ethArr,2);
        % Defining start point to align with
%         timeOffset = ethArr{1,1}(1).time;
        timeMin = ethArr{1,1}(1).time;
        for j = 1 : graphNum  
         if ethArr{1,j}(1).time > 30
             % It is not a scope measurement
            if exist('timeOffset','var') && ethArr{1,j}(1).time<timeOffset
                timeOffset = ethArr{1,j}(1).time;
            else                             
                timeOffset = ethArr{1,j}(1).time;
            end
         end   
         if ethArr{1,j}(1).time < timeMin
            timeMin = ethArr{1,j}(1).time;
         end
        end
        
        if ~exist('timeOffset','var')
            timeOffset = timeMin;
        end
        
        txt1 = findobj(fig,'Tag','txtLeftBorder');
        txt2 = findobj(fig,'Tag','txtRightBorder');                
        timeLabel   = findobj(fig,'Tag','measuredAtTimeLabel');
        timeMsg     = strsplit(datestr(timeOffset/86400 + datenum(1970,1,1)),' ');
        timeMsg     = sprintf('%s\n%s',timeMsg{1,1},timeMsg{1,2});
        timeLabel.String = timeMsg;      
        i = 2;  
        
        % Checking passed function properties
        while i <= size(varargin,2)
            switch lower(varargin{i})
                case 'time'
                    startTime   = varargin{i+1}(1);
                    endTime     = varargin{i+1}(2);         
                    txt1.String = startTime;
                    txt2.String = endTime;                    
                    i = i + 2;
                case 'packetnumrange'                 
                    alignedMeasurementNum = varargin{i+1};                    
                    
                    if alignedMeasurementNum > size(varargin{1},2)
                        error('You have input wrong measurement number');
                    end                    
                    
                    leftBorder  = varargin{i+2}(1);
                    rightBorder = varargin{i+2}(2);                                          
                    tempArr     = ethArr{alignedMeasurementNum};
                    ethPcktNum  = [tempArr.packetNum];
                    ethArrIdx   = find(ethPcktNum >= leftBorder & ethPcktNum <= rightBorder);                     
                    startTime   = tempArr(ethArrIdx(1)).time;
                    endTime     = tempArr(ethArrIdx(end)).time;
                    fullLength  = endTime - startTime;
                    startTime   = startTime - 0.05*fullLength;
                    endTime     = endTime + 0.05*fullLength;                    
                    txt1.String = leftBorder;
                    txt2.String = rightBorder;                    
                    i = i + 3;
                case 'names'
                    % User defined axes names should be passed as cell array of strings
                    customAxesNames = varargin{i+1};

                    if size(customAxesNames,2) ~= size(ethArr,2)
                        warndlg('You have passed wrong axes naming argument.');
                        clear customAxesNames;
                    end

                    i = i + 2;
                case 'colors'
                    % User defined colors {[0 1 1], [0 1 0], [0 1 1]}
                    inputColorArr = varargin{i+1};

                    if ~isempty(inputColorArr)
                        if size(inputColorArr,2) ~= size(ethArr,2) && size(inputColorArr,2) ~= 1
                            warndlg('The size of color array does not match to the passed objcet array. Default colors will be used.');
                            inputColorArr = {};
                        end                        
                        % Enable Coloring Panel
                        btnGroup = findobj(fig, 'Tag', 'ColoringOptionGroup');
                        set(allchild(btnGroup),'Enable','on');  
                        % Select user defined option and                         
                        radiobuttons = allchild(btnGroup);        
                        userColorBtn = findobj(radiobuttons,'Tag','userColoringRadioBtn');
                        userColorBtn.Value = 1;                        
                    end

                    i = i + 2;   
            end
        end
        
        if ~exist('startTime','var')
            startTime = 0;        
            txt1.String = startTime;
        end

        if ~exist('endTime','var')
            endTime = 0.1;
            txt2.String = endTime;
        end
        
        % Check if the end time is not a lot bigger than max time
        ethFullArr = [ethArr{:}];
        ethTimeMax = max([ethFullArr.time])-timeOffset;
        if endTime > ethTimeMax
            endTime     = ethTimeMax;
            txt2.String = endTime;   
        end
        clear {'ethFullArr', 'ethTimeMax'};

        % Initial Variables
        SpeedMBPS   = 100;
        sPerBit     = 1 / (SpeedMBPS * 10^6);
        sPerEncodedByte = 8 * sPerBit;
        displayedPackets= 0;
        RECT_LENGTH_S   = sPerEncodedByte;
        TimeStartS  = startTime; 
        TimeEndS    = endTime;        
        lineWidth   = 0.02;
        YTicks      = 1:graphNum;
        YTicksLabel = cell(1,graphNum);              
        timeMaxArr  = zeros(1,graphNum);   
        loadingLbl  = findobj(fig, 'Tag', 'timeLimiter');

        % Delete non-relevant axes if any        
        overlayAxes = findobj('Type','axes','-and','UserData','overlayAxe');

        if ( ~isempty(overlayAxes) )
            delete(overlayAxes);
        end        
        
        hiddenAxes = findobj('Type','axes','-and','UserData','hiddenYTick');                

        if ~isempty(hiddenAxes)
            delete(hiddenAxes);
        end        

        % Define desired packet colors at 'colors' file in an application directory
        fileID = fopen('config/colors');
        colorInfo = textscan(fileID,'%s %f %f %f','CommentStyle','%','Delimiter',',');                    
        if ~isempty(colorInfo)
            colorNames = {colorInfo{1}{:}};
        end
        % Displaying packets on defined range    
        for j = 1 : graphNum  

            % Nifty small loading status
            if (strcmp(loadingLbl.String,'< counting..'))
                loadingLbl.String = '< counting.';
            else
                loadingLbl.String = '< counting..';
            end

            curArr = ethArr{j};     
            if ethArr{j}(end).time < 50
                % It is a scope file
                timeMaxArr(j) = ethArr{j}(end).time + ethArr{j}(1).time;
            else
                timeMaxArr(j) = ethArr{j}(end).time-timeOffset;
            end
                
            YAxe = graphNum + 1 - j;           
            t = 0;
            i = 1;
            startTime = curArr(i).time;
            % Draw an X axis line
            rectangle ( 'Position' , [TimeStartS-(TimeEndS-TimeStartS)*0.05 YAxe-(lineWidth/2) 1.1*(TimeEndS-TimeStartS) lineWidth],...
                        'FaceColor' , [0.33 0.33 0.33],...
                        'EdgeColor', 'None', ...
                        'HitTest', 'Off', ...
                        'UserData', 'XAxe');     

            while t<TimeEndS && i <= length(curArr)   
            % Timescale is aligned by the lowest packet time
                if curArr(1).time < 30
                    % It is a scope file
                    t = curArr(i).time;
                else
                    t = curArr(i).time-timeOffset;
                end
                
                if t>=TimeStartS && t<=TimeEndS

                    axis([TimeStartS inf 0 graphNum+1]);
                    packetLength    = RECT_LENGTH_S * (curArr(i).packetLen);
                    packetTimeEnd   = t + packetLength;
                    % Compare packet description with predefined colornaming array
                    % Draw a packet with a rectangle function
                    % index = find(not(cellfun('isempty', strfind(colorNames, curArr(i).packetDesc))));
                    index= [];
                    if ~isempty(index)
                        % Draw packet with defined color
                        rectangle ( 'Position', [t YAxe-(3.5*lineWidth) packetLength lineWidth*7],...
                                    'FaceColor', [colorInfo{2}(index)/255 colorInfo{3}(index)/255 colorInfo{4}(index)/255],...
                                    'ButtonDownFcn',@packetClick,...
                                    'EdgeColor',[colorInfo{2}(index)/255 colorInfo{3}(index)/255 colorInfo{4}(index)/255],...
                                    'UserData', [j curArr(i).packetNum]);                        
                    else
                        % Draw packet with default color
                        rectangle ( 'Position', [t YAxe-(3.5*lineWidth) packetLength lineWidth*7],...
                                    'FaceColor', 'blue',...
                                    'ButtonDownFcn',@packetClick,...
                                    'EdgeColor','blue',...
                                    'UserData', [j curArr(i).packetNum]);                        
                    end

                    % Display packet number above the packet itself
                    h = text( t, YAxe+4.5*lineWidth, num2str(curArr(i).packetNum));
                    set(h,'Clipping','on');
                    set(h,'HitTest','off');
                    set(h,'PickableParts','none');
                    displayedPackets = displayedPackets + 1;
                    t = packetTimeEnd;
                    
                end      

                i = i + 1;        
            end

            % Name Y tick labels and table data and popup menu
            if ~exist('customAxesNames','var')
                YTicksLabel{YAxe} = strcat('M', num2str(j));                
            else
                YTicksLabel{YAxe} = customAxesNames{j};
                tb = findobj(fig, 'Tag', 'fileTable');
                pm = findobj(fig, 'Tag', 'pmDispOptions');
                tb.Data{j,1}     = customAxesNames{j};                
                pm.String{j+1,1} = customAxesNames{j};
            end
            
        end

        msg = sprintf('< %.2f sec.',max(timeMaxArr));
        loadingLbl.String   = msg;
        packetCountText     = text(1,1,[num2str(displayedPackets),' packets'],'Units','normalized','HitTest','Off');    
        packetCountText.Tag = 'packetCount';
        ax = gca();  
        ax.XLim     = [TimeStartS-(TimeEndS-TimeStartS)*0.05 TimeStartS + 1.05*(TimeEndS-TimeStartS)];
        ax.YTick    = YTicks;    
        ax.YTickLabel    = YTicksLabel;
        ax.ClippingStyle = 'rectangle';
        initialScale     = ax.XLim;

        if ~isempty(inputColorArr)
            colorAxes(ax,inputColorArr);
        end
        
        toc

    end

    function resizeCallbackFcn (obj, event_obj)
    % Function to keep axes at the same YScale        
        if ~isempty(jLabel)

            if isa(jLabel,'javahandle_withcallbacks.javax.swing.JLabel')
                delete(jLabel);
            end

        end    

        newLim = event_obj.Axes.XLim;   
        axesObj = event_obj.Axes;
        axesObj.YLim = [0 size(varargin{1},2)+1];

        if (initialScale(1)>newLim(1) || initialScale(2)<newLim(2))            
            axesObj.XLim = initialScale; 
        end

    end

end