%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %%                           SCOPE CLASS                              %%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    Author: Frederic Depuydt                                          %
%  %    Company: KU Leuven                                                %
%  %    Contact: frederic.depuydt@kuleuven.be; f.depuydt@outlook.com      %
%  %    Version: 1.3                                                      %
%  %                                                                      %
%  %    An Scope class to analyse scope signals                           %
%  %    Readable files: isf, csv                                          %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        FUNCTIONS (static)                 *Object creation*          %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    usage: objScope = scope.function(var1, var2, ...)                 %
%  %                                                                      %
%  %    isfread(                Reading scope signals from an ISF file    %
%  %        file,                   Filename + extension as String        %
%  %        verbose)                Integer to enable verbose mode        %
%  %                                                                      %
%  %    csvread(                DEPRECATED! Reading from a CSV file       %
%  %        file,                   Filename + extension as String        %
%  %        channels,               Array of strings refering to channels %
%  %        verbose,                Integer to enable verbose mode        %
%  %        retime)                 Calculate more accurate timestamps    %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        FUNCTIONS (non-static)                                        %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    usage: result = objScope.function(var1, var2, ...)                %
%  %    note: most functions do not alter the original scope object,      %
%  %          but return a new object with the function results           %
%  %                                                                      %
%  %    values(                 Returning the values of a channel         %
%  %        channels)               Array of strings refering to channels %
%  %            returns: matrix of the requested values                   %
%  %                                                                      %
%  %    split(                  Splitting 1 scope object into 2 (a and b) %
%  %        channels_a,             Array of strings refering to channels %
%  %        channels_b)             Array of strings refering to channels %
%  %            returns: [objScope1, objScope2]                           %
%  %                                                                      %
%  %    downsample(             Lowering the amount of sample rate        %
%  %        samples,                The new number of samples             %
%  %        verbose)                Integer to enable verbose mode        %
%  %            returns: downsampled scope object                         %
%  %                                                                      %
%  %    remove(                 Removing channels from a Scope object     %
%  %        channels,               Array of strings refering to channels %
%  %        verbose)                Integer to enable verbose mode        %
%  %            returns: scope object without the removed channels        %
%  %                                                                      %
%  %    noisefilter(            Filters noise from requested channels     %
%  %        values,                 The input values you want to filter   %
%  %        threshold,              Threshold value to be filtered        %
%  %        verbose)                Integer to enable verbose mode        %
%  %            returns: filtered output values                           %
%  %                                                                      %
%  %    bandstop(               Filtering by frequencybands               %
%  %        values,                 The input values you want to filter   %
%  %        freq,                   Array of frequentybands to be filtered%
%  %        verbose)                Integer to enable verbose mode        %
%  %            returns: filtered output values                           %
%  %                                                                      %
%  %    scale(                  Scaling values of the requested channels  %
%  %        channels,               Array of strings refering to channels %
%  %        target,                 Target value to which to scale to     %
%  %        verbose)                Integer to enable verbose mode        %
%  %            returns: nothing, results directly applied on scope object%
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

classdef scope
    properties
        model, ...
            firmware_version, ...
            waveform_type, ...
            point_format, ...
            horizontal_units, ...
            horizontal_scale, ...
            horizontal_delay, ...
            sample_interval,...
            filter_frequency, ...
            record_length, ...
            sample_length, ...
            gating, ...
            gating_min, ...
            gating_max, ...
            probe_attenuation, ...
            vertical_units, ...
            vertical_offset, ...
            vertical_scale, ...
            vertical_position, ...
            time, ...
            channels, ...
            value
    end
    methods
        function obj = scope(model)
            obj.model = model;
        end
        function result = values(obj,str)
            for i=1:length(obj.channels)
                if(strcmp(str,obj.channels{i}))
                    result = obj.value{i};
                end
            end
        end
        %        function fft(obj,str)
        %             if(~exist('strength','var'));strength=0.0001;end;
        %             for i=1:length(obj.channels)
        %                 if(strcmp(str,obj.channels{i}))
        %                     F = fft(obj.value{i});
        %                 end
        %             end
        %         end
        function [obj1,obj2] = split(obj,channels1,channels2)
            obj1 = obj;
            obj2 = obj;
            obj1.channels = {};
            obj2.channels = {};
            obj1.value = {};
            obj2.value = {};
            k1 = 1;
            k2 = 1;
            for i=1:length(obj.channels)
                for j=1:length(channels1)
                    if(strcmp(channels1(j),obj.channels{i}))
                        obj1.channels{k1}=obj.channels{i};
                        obj1.value{k1}=obj.value{i};
                        k1 = k1+1;
                    end
                end
                for j=1:length(channels2)
                    if(strcmp(channels2(j),obj.channels{i}))
                        obj2.channels{k2}=obj.channels{i};
                        obj2.value{k2}=obj.value{i};
                        k2 = k2+1;
                    end
                end
            end
        end
        function obj = downsample(obj,samples,verbose)
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if(~exist('samples','var'));return;end;
            n = obj.sample_length/samples;
            if(n>1 && mod(n,1)==0)
                newobj = obj;
                newobj.sample_interval = n*obj.sample_interval;
                newobj.sample_length = obj.sample_length/n;
                obj.time = mean(reshape(obj.time,n,[]));
                for i=1:length(obj.channels)
                    obj.value{i} =  mean(reshape(obj.value{i},n,[]));
                end
            else
                error('Impossible downsample');
            end
        end
        function obj = remove(obj,channels,verbose)
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if(~exist('channels','var'));return;end;
            for j=1:length(channels)
                for i=length(obj.channels):-1:1
                    if(strcmp(channels(j),obj.channels(i)))
                        obj.channels(i)=[];
                        obj.value(i)=[];
                    end
                end
            end
        end
        function Y = noisefilter(obj,X,threshold,verbose)
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if(~exist('threshold','var'));threshold=0.0001;end;
            % Initial Values
            Fs = 1/obj.sample_interval;  % Sampling frequency
            T = 1/Fs;                    % Sampling period
            L = obj.sample_length;       % Length of signal
            F = fft(X);
            P1 = abs(F/L);
            F(P1<threshold)=0;
            Y = ifft(F);
            if(verbose)
                figure;
                P2 = abs(fft(Y)/L);
                ax = plt.getaxis(obj.time,[X,Y]);
                subplot(2,1,1);
                plt(obj.time,X,'downsample',1e6,color.ch1);
                title('Original signal');
                xlabel('t(s)');
                ylabel('X(t)');
                axis(ax);
                subplot(2,1,2);
                plt(obj.time,Y,'downsample',1e6,color.ch1);
                title('Filtered signal');
                xlabel('t(s)');
                ylabel('X(t)');
                axis(ax);
                
                figure;
                f = Fs*(0:ceil(L/2))/L;
                subplot(2,1,1);
                P1 = P1(1:ceil(L/2)+1);
                ax = [1 max(f) min(P1(P1>10^(-10))) 1];
                loglog(f,P1,color.ch2);
                title('Single-Sided Amplitude Spectrum of P1(t)');
                xlabel('f (Hz)');
                ylabel('|P1(f)|');
                axis(ax);
                subplot(2,1,2);
                P2 = P2(1:ceil(L/2)+1);
                loglog(f,P2,color.ch2);
                title('Single-Sided Amplitude Spectrum of P2(t)');
                xlabel('f (Hz)');
                ylabel('|P2(f)|');
                axis(ax);
            end
        end
        function Y = bandstop(obj,X,freq,verbose)
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if(verbose);tic;end;
            if(~exist('freq','var')); Y=X; warn('No frequency range given, returned without filtering');return;end;
            if(size(freq,2) ~= 2); Y=X; warn('Frequency range invalid, returned without filtering');return;end;
            % Initial Values
            Fs = 1/obj.sample_interval;  % Sampling frequency
            L = obj.sample_length;       % Length of signal
            F = fft(X);
            P1 = F;
            for i = 1:size(freq,1)
                locmin([1,2]) = round(freq(i,1)*L/Fs)+1;
                locmax([1,2]) = round(freq(i,2)*L/Fs)+1;
                if(locmin(1)<1);locmin(1)=1;end;
                if(locmax(1)<1);locmax(1)=1;end;
                if(locmin(2)<2);locmin(2)=2;end;
                if(locmax(2)<2);locmax(2)=2;end;
                if(locmin(1)>length(F)/2);locmin(1)=round(length(F)/2);end;
                if(locmax(1)>length(F)/2);locmax(1)=round(length(F)/2);end;
                if(locmin(2)>length(F)/2);locmin(2)=round(length(F)/2);end;
                if(locmax(2)>length(F)/2);locmax(2)=round(length(F)/2);end;
                L1 = locmin(1):locmax(1);
                L2 = length(F)-(locmax(2)-2):length(F)-(locmin(2)-2);
                F(L1) = 0;
                F(L2) = 0;
            end
            Y = real(ifft(F));
            if(verbose)
                toc
                P1 = abs(P1/L);
                P2 = abs(fft(Y)/L);
                figure;
                %ax = plt(obj.time,[X,Y]);
                subplot(2,1,1);
                plt(obj.time,X,'downsample',1e5,color.ch1);
                title('Original signal');
                xlabel('t(s)');
                ylabel('X(t)');
                %axis(ax);
                subplot(2,1,2);
                plt(obj.time,Y,'downsample',1e5,color.ch1);
                title('Filtered signal');
                xlabel('t(s)');
                ylabel('X(t)');
                %axis(ax);
                
                figure;
                f = Fs*(0:ceil(L/2))/L;
                subplot(2,1,1);
                P1 = P1(1:ceil(L/2)+1);
                ax = [1 max(f) min(P1(P1>10^(-10))) 1];
                loglog(f,P1,color.ch2);
                title('Single-Sided Amplitude Spectrum of P1(t)');
                xlabel('f (Hz)');
                ylabel('|P1(f)|');
                axis(ax);
                subplot(2,1,2);
                P2 = P2(1:ceil(L/2)+1);
                loglog(f,P1,color.lightgrey);
                axis(ax);
                hold on;
                loglog(f,P2,color.ch2);
                title('Single-Sided Amplitude Spectrum of P2(t)');
                xlabel('f (Hz)');
                ylabel('|P2(f)|');
                axis(ax);
                hold off;
            end
        end
        function Y = getValues(obj,channel)
            if(~exist('channel','var'));error('No channel selected');end;
            if(isnumeric(channel))
                Y = obj.value{channel};
            else
                Y = obj.values(channel);
            end
                
        end
        function scale(obj,str,target)
            if(~exist('pass','var'));target=0;end;
            for i=1:length(obj.channels)
                if(strcmp(str,obj.channels{i}))
                    YS = sort(obj.value{i},1, 'ascend');
                    fault = mean(YS(1:ceil(0.03*size(YS,1))))-target;
                    obj.value{i} = obj.value{i} - fault;
                end
            end
        end
    end
    methods (Static)
        function obj = isfread(file, verbose)
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if ~exist('file', 'var')
                error('No file name, directory or pattern was specified.');
            end
            
            % Check whether file is a folder.
            if( exist(file, 'dir') )
                folder = file;
                % Get a list of all files that have the extension '.isf' or '.ISF'.
                files = [ dir(fullfile(folder, '*.isf')) ];
            else
                % The pattern is not a folder, so must be a file name or a pattern with
                % wildcards (such as 'Traces/TEK0*.ISF').
                [folder, ~, ~] = fileparts(file);
                % Get a list of all files and folders which match the pattern...
                filesAndFolders = dir(file);
                % ...then exclude the folders, to get just a list of files.
                files = filesAndFolders(~[filesAndFolders.isdir]);
            end
            
            fileNames = {files.name};
            datetimes = datestr([files.datenum]);
            
            if numel(fileNames)==0
                error('The pattern did not match any file or files: %s', file);
            end
            
            obj = scope('Unknown (ISF)');
            obj.firmware_version = 'Unknown (ISF)';
            
            for s=1:numel(fileNames)
                fileName = fileNames{s};
                fullFileName = fullfile(folder, fileName);
                
                % Check the file exists.
                if( ~exist(fullFileName, 'file') )
                    error('The file does not exist: %s', fullFileName);
                end
                
                % Open the file.
                fileID = fopen( fullfile(folder, fileName), 'r');
                if (fileID == -1)
                    error('The file exists, but could not be opened: %s', fullFileName);
                end
                
                % Read the text header into a variable called 'h'. The loop reads the
                % file character-by-character into h until h finishes with the
                % characters ":CURVE #" or ":CURV #".
                h = '';
                while( isempty( regexp(h, ':CURVE? #', 'once') ) )
                    % If the end of the file has been reached something is wrong.
                    if( feof(fileID) )
                        error('The end of the file %s was reached whilst still reading the header. This suggests that it is not a Tektronix ISF file.', fileName);
                    end
                    c = char(fread(fileID, 1, 'char') );
                    h = [h, c];
                end
                
                if s==1
                    obj.waveform_type       = char(regexp(h, 'WFMTYP?E?\s+(.*?)\s*[;:]', 'once', 'tokens'));
                    obj.point_format        = char(regexp(h, 'PT_FM?T?\s+(.*?)\s*[;:]', 'once', 'tokens'));
                    obj.horizontal_units    = char(regexp(h, 'XUNI?T?\s+"*(.*?)"*[;:]', 'once', 'tokens'));
                    obj.horizontal_scale    = str2double(regexp(h, 'HSCAL?E?\s+([-\+\d\.eE]+)', 'once', 'tokens'));
                    obj.horizontal_delay    = str2double(regexp(h, 'HDELA?Y?\s+([-\+\d\.eE]+)', 'once', 'tokens'));
                    obj.sample_interval     = str2double(regexp(h, 'XINC?R?\s+([-\+\d\.eE]+)', 'once', 'tokens'));
                    obj.record_length       = 'Unknown (ISF)';
                    obj.gating              = 'Unknown (ISF)';
                    obj.gating_min          = 'Unknown (ISF)';
                    obj.gating_max          = 'Unknown (ISF)';
                    obj.sample_length       = str2double(regexp(h, 'NR_PT?\s+(\d+)', 'once', 'tokens'));
                else
                    if obj.waveform_type    ~= char(regexp(h, 'WFMTYP?E?\s+(.*?)\s*[;:]', 'once', 'tokens'))
                        error('Waveform Type does not match');
                    end
                    if obj.point_format     ~= char(regexp(h, 'PT_FM?T?\s+(.*?)\s*[;:]', 'once', 'tokens'));
                        error('Point Format does not match');
                    end
                    if obj.horizontal_units ~= char(regexp(h, 'XUNI?T?\s+"*(.*?)"*[;:]', 'once', 'tokens'));
                        error('Horizontal Units do not match');
                    end
                    if obj.horizontal_scale ~= str2double(regexp(h, 'HSCAL?E?\s+([-\+\d\.eE]+)', 'once', 'tokens'));
                        error('Horizontal Scale does not match');
                    end
                    if obj.horizontal_delay ~= str2double(regexp(h, 'HDELA?Y?\s+([-\+\d\.eE]+)', 'once', 'tokens'));
                        error('Horizontal Delay does not match');
                    end
                    if obj.sample_length    ~= str2double(regexp(h, 'NR_PT?\s+(\d+)', 'once', 'tokens'));
                        error('Sample Length does not match');
                    end
                    if obj.sample_interval   ~= str2double(regexp(h, 'XINC?R?\s+([-\+\d\.eE]+)', 'once', 'tokens'));
                        error('Sample Interval does not match');
                    end
                end
                
                % In addition, some header fields are described in the Programmer
                % Manual, but do not seem to appear in any of my files: XMULT, XOFF,
                % XZERO, ZMULT, ZOFF, ZUNIT and ZZERO.
                
                % Check that at least some part of the header was parsed.
                if isempty(str2double(regexp(h, 'BYT_NR?\s+(\d+)', 'once', 'tokens')))
                    warn('Failed to read some part of, or possibly all of, the header in the file %s.', fileName);
                end
                
                BYT_N = str2double(regexp(h, 'BYT_NR?\s+"*(.*?)"*[;:]', 'once', 'tokens'));
                BIT_N = str2double(regexp(h, 'BIT_NR?\s+"*(.*?)"*[;:]', 'once', 'tokens'));
                
                % The next few characters in the file give the number of bytes in the
                % waveform data. The first digit, referred to as 'x' on page 2-60 of
                % the Programmer Manual, gives the number of bytes that immediately
                % follow giving the value 'y', where 'y' is the number of bytes in the
                % waveform. The manual explains it better than I can.
                xBytes = str2double(char(fread(fileID, 1, 'char')));
                yBytes = str2double(char(fread(fileID, xBytes, 'char')));
                
                % For some reason there is an offset of 1 byte in reading the data
                % files. I don't know why, but I found I could fix it by moving the
                % file position back by one byte.
                fseek(fileID, -1, 'cof');
                
                % Read the waveform.
                % For some oscilloscopes it may be necessary to add 'ieee-be' to the
                % fread statement below. See the comments here:
                % http://www.mathworks.co.uk/matlabcentral/fileexchange/6247-isfread
                if(BYT_N == 2 && BIT_N == 16)
                    [binaryData, count] = fread(fileID, yBytes/2, 'int16');
                elseif (BYT_N == 1 && BIT_N == 8)
                    [binaryData, count] = fread(fileID, yBytes, 'int8');
                else
                    error(['BYT_N ' num2str(BYT_N) ' BIT_N ' num2str(BIT_N) ' - Unknown ISF structure']);
                end
                % Check that the expected number of points have been read.
                if(count ~= obj.sample_length)
                    error('According to the header, the file %s contains %d points, but only %d were read.', fileName, obj.sample_length, count);
                end
                
                % Check that there is no leftover data. I found that there generally
                % is.
                if( ~feof(fileID) )
                    warn('All expected data was read from %s, but there still appears to be data remaining.', fileName);
                end
                
                % Calculate the horizontal (x) and vertical (y) values. These equations
                % are given on page 2-171 of the Programmer Manual.
                n = (1:obj.sample_length)';
                if s==1
                    obj.time = (obj.sample_interval * (n - str2double(regexp(h, 'PT_OF?F?\s+([-\+\d\.eE]+)', 'once', 'tokens'))))' - obj.horizontal_delay; 
                end
                
                obj.channels{s} = char(regexp(h, 'WFID?\s+"*\s*(.*?)\s*"*[;:]', 'once', 'tokens'));
                obj.value{s} = (str2double( regexp(h, 'YZER?O?\s+([-\+\d\.eE]+)', 'once', 'tokens')) + str2double(regexp(h, 'YMUL?T?\s+([-\+\d\.eE]+)', 'once', 'tokens')) * (binaryData - str2double(regexp(h, 'YOFF?\s+([-\+\d\.eE]+)', 'once', 'tokens'))))';
                                
                % Close the file
                fclose(fileID);
                
            end
        end
        
        function obj = wfmread(file, verbose)
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if ~exist('file', 'var')
                error('No file name, directory or pattern was specified.');
            end
            
            % Check whether file is a folder.
            if( exist(file, 'dir') )
                folder = file;
                % Get a list of all files that have the extension '.isf' or '.ISF'.
                files = [ dir(fullfile(folder, '*.isf')) ];
            else
                % The pattern is not a folder, so must be a file name or a pattern with
                % wildcards (such as 'Traces/TEK0*.ISF').
                [folder, ~, ~] = fileparts(file);
                % Get a list of all files and folders which match the pattern...
                filesAndFolders = dir(file);
                % ...then exclude the folders, to get just a list of files.
                files = filesAndFolders(~[filesAndFolders.isdir]);
            end
            
            fileNames = {files.name};
            datetimes = datestr([files.datenum]);
            
            if numel(fileNames)==0
                error('The pattern did not match any file or files: %s', file);
            end
            
            obj = scope('Unknown (WFM)');
            obj.firmware_version = 'Unknown (WFM)';
            
            for s=1:numel(fileNames)
                fileName = fileNames{s};
                fullFileName = fullfile(folder, fileName);
                
                % Check the file exists.
                if( ~exist(fullFileName, 'file') )
                    error('The file does not exist: %s', fullFileName);
                end
                
                % Read the file.
                [y, t, info] = wfm2read(fullFileName);
                
                obj.waveform_type       = info.versioning_number;
                obj.sample_interval     = 1/info.samplingrate;
                obj.record_length       = 'Unknown (WFM)';
                obj.gating              = 'Unknown (WFM)';
                obj.gating_min          = 'Unknown (WFM)';
                obj.gating_max          = 'Unknown (WFM)';
                obj.sample_length       = info.nop;
              
                obj.time = t';
                
                obj.channels{s} = 'CH1';
                obj.value{s} = y';
                
            end
        end
        
        
        function obj = csvread(file,channels,verbose,retime)
            if(~exist('verbose','var'));verbose=-1;warn('All underlying functions are executed in verbose mode');end;
            if(~exist('retime','var'));retime=1;end;
            if(~exist('channels','var'));channels={'CH1','CH2','CH3','CH4'};end;
            if(isempty(channels));channels={'CH1','CH2','CH3','CH4'};end;
            if(~exist('file','var'))
                % Ask user for file name
                % check if file exists
            end
            fid = fopen(file);
            cell = textscan(fid, '%*s %s %*s %f', 1, 'delimiter', {',','\n'}, 'headerlines', 0);
            obj = scope(cell{1}{1});
            if strcmp(obj.model,'DPO4054B')
                %% DPO4054B
                obj.firmware_version = cell{2};
                if(verbose);disp('Reading waveform of Tektronix DPO4054B');end;
                DPO4054B_supp_fw = [3.16 3.18 3.20];
                if sum(obj.firmware_version==DPO4054B_supp_fw) == 0
                    if(verbose);warn(['Unsupported version (' num2str(obj.firmware_version) ')']);end;
                    fclose(fid);
                    return;
                end
                cell = textscan(fid, '%s', 8, 'delimiter', {'\n'}, 'headerlines', 1);cell=cell{1};
                [ans cell] = strtok(cell,',');
                cell = strtok(cell,',');
                obj.waveform_type       = cell{1};
                obj.point_format        = cell{2};
                obj.horizontal_units    = cell{3};
                obj.horizontal_scale    = str2double(cell{4});
                obj.horizontal_delay    = str2double(cell{5});
                obj.sample_interval     = str2double(cell{6});
                obj.record_length       = str2double(cell{7});
                obj.gating              = cell{8};
                
                cell = textscan(obj.gating , '%f %f', -1, 'delimiter', {' to ','%'});cell=cell{1};
                obj.gating_min          = cell(1);
                obj.gating_max          = cell(2);
                
                
                obj.sample_length = obj.record_length*((obj.gating_max-obj.gating_min)/100);
                
                
                cell = textscan(fid, '%s', 10, 'delimiter', {'\n'}, 'headerlines', 0);cell=cell{1};
                cell_channels = textscan(cell{10}, '%s', -1, 'delimiter', {','});cell_channels=cell_channels{1};
                fclose(fid);
                data = csvread(file,21,0)';
                obj.time = data(1,1:obj.sample_length);
                if(retime)
                    %retime
                    [minV,minID] = min(abs(obj.time));
                    low = minV-(minID-1)*obj.sample_interval;
                    high = low + obj.sample_length*obj.sample_interval;
                    obj.time = linspace(low,high,obj.sample_length);
                end
                
                k=1;
                for j=1:length(channels)
                    for i=1:length(cell_channels)
                        if(strcmp(channels{j},cell_channels{i}))
                            obj.channels{k} = cell_channels{i};
                            obj.value{k} = data(i,1:obj.sample_length);
                            k=k+1;
                        end
                    end
                end
            elseif strcmp(obj.model,'DPO2024')
                %% DPO2024
                obj.firmware_version = cell{2};
                if(verbose);disp('Reading waveform of Tektronix DPO2024');end;
                if obj.firmware_version ~= 1.52
                    if(verbose);warn(['Unsupported version (' num2str(obj.firmware_version) ')']);end;
                    fclose(fid);
                    return;
                end
                cell = textscan(fid, '%*s %s %*s', 7, 'delimiter', {',','\n'}, 'headerlines', 1);cell=cell{1};
                obj.point_format        = cell{1};
                obj.horizontal_units    = str2double(cell{2});
                obj.horizontal_scale    = str2double(cell{3});
                obj.sample_interval     = str2double(cell{4});
                obj.filter_frequency    = str2double(cell{5});
                obj.record_length       = str2double(cell{6});
                obj.gating              = cell{7};
                
                cell = textscan(obj.gating , '%f %f', -1, 'delimiter', {' to ','%'});cell=cell{1};
                obj.gating_min          = cell(1);
                obj.gating_max          = cell(2);
                
                
                obj.sample_length = obj.record_length*((obj.gating_max-obj.gating_min)/100);
                
                
                cell = textscan(fid, '%s', 6, 'delimiter', {'\n'}, 'headerlines', 0);cell=cell{1};
                cell_channels = textscan(cell{6}, '%s', -1, 'delimiter', {','});cell_channels=cell_channels{1};
                fclose(fid);
                data = csvread(file,16,0)';
                obj.time = data(1,1:obj.sample_length);
                if(retime)
                    %retime
                    [minV,minID] = min(abs(obj.time));
                    low = minV-(minID-1)*obj.sample_interval;
                    high = low + obj.sample_length*obj.sample_interval;
                    obj.time = linspace(low,high,obj.sample_length);
                end
                
                k=1;
                for j=1:length(channels)
                    for i=1:length(cell_channels)
                        if(strcmp(channels{j},cell_channels{i}))
                            obj.channels{k} = cell_channels{i};
                            obj.value{k} = data(i,1:obj.sample_length);
                            k=k+1;
                        end
                    end
                end
            else
                if(verbose);warn(['Unsupported scope (' num2str(obj.model) ')']);end;
                fclose(fid);
            end
        end
    end
end
