%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %%                             TEK CLASS                              %%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    Author: Frederic Depuydt                                          %
%  %    Company: KU Leuven                                                %
%  %    Contact: frederic.depuydt@kuleuven.be; f.depuydt@outlook.com      %
%  %    Version: 1.1                                                      %
%  %                                                                      %
%  %    An Tek class for remote use of Tektronics Scopes                  %
%  %    Usable oscilloscopes: DPO4054B                                    %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        FUNCTIONS (static)                 *Object creation*          %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    objTek = tek(               Constructor                           %
%  %                model,              model name as string              %
%  %                ip_address,         IP address as string              %
%  %                port)               port as integer                   %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        FUNCTIONS (non-static)                                        %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    usage: result = objTek.function(var1, var2, ...)                  %
%  %                                                                      %
%  %    connect()               Open the connection to the oscilloscope   %
%  %                                                                      %
%  %    single()                Set oscilloscope in single shot mode      %
%  %                                                                      %
%  %    trigger()               Force a trigger on the oscilloscope       %
%  %                                                                      %
%  %    readwaveform(           Lowering the amount of sample rate        %
%  %        channels)               Channels to read as string array      %
%  %            returns: objScope with time and values of read channels   %             
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

classdef tek < handle
    properties (SetAccess = immutable)
        model    
    end
    properties (SetAccess = private)
        status   
    end
    properties
        ip_address , ...
            port
    end
    properties (Access = private)
        interface , ...
         device , ...
     mdd
    end
    methods
        function obj = tek(model,ip_address,port)
            % HELP FOR TEK CONSTRUCTOR FUNCTION
            if(~exist('model','var'));error('No model');end;
            if strcmp(model,'DPO4054B')
                obj.model = 'DPO4054B';
                obj.status = 'created';
                obj.mdd = 'DPO4054B.mdd';
                if(exist('ip_address','var')); obj.ip_address = ip_address; end;
                if(exist('port','var')); obj.port = port; end;
                try
                    obj.create_interface();
                    obj.create_device();
                catch
                    warn('Interface or Device not created yet');
                end
            else
                error('Unsupported model');
            end
        end
        function connect(obj)
            if(isempty(obj.device));error('No Device');end;
            connect(obj.device);
            obj.status = 'connected';
        end
        function trigger(obj)
            if(obj.isconnected())
                groupObj = get(obj.device, 'Trigger');
                invoke(groupObj, 'trigger');
            else
                warning('Device not connected');
            end
        end
        function single(obj)
            if(obj.isconnected())
                set(obj.device.Acquisition(1), 'Control', 'single');
                set(obj.device.Acquisition(1), 'State', 'run');
            else
                warning('Device not connected');
            end
        end
        function objScope = readwaveform(obj,channels)
            if(obj.isconnected())
               %% Reading scope data
                objScope = scope(obj.model);
                objScope.record_length = 20000000;
                groupObj = get(obj.device, 'Waveform');
                         
                
                set(groupObj, 'FirstPoint', 1);
                set(groupObj, 'EndingPoint', 20000000);
                
                if(~iscell(channels)); tmp{1} = channels; channels = tmp; clear tmp; end;
                for i=1:length(channels)
                    try
                        [objScope.value{i}, objScope.time] = invoke(groupObj, 'readwaveform', channels{i});
                        objScope.channels{i} = channels{i};
                    catch
                        error([channels{i} ' couldnt be read in.']);
                    end
                end                
                objScope.sample_interval =   objScope.time(2) -  objScope.time(1);
            else
                warning('Device not connected');
            end
        end
    end
    methods (Access = private)
        function create_interface(obj)
            if(isempty(obj.ip_address));error('No IP-address');end;
            if(isempty(obj.port));error('No Port');end;
            
            obj.interface = instrfind('Type', 'tcpip', 'RemoteHost', obj.ip_address, 'RemotePort', obj.port, 'Tag', '');       
            if isempty(obj.interface)
                % Create the TCPIP object if it does not exist
                obj.interface = tcpip(obj.ip_address, obj.port);
            else
                 % otherwise use the object that was found.
                fclose(obj.interface);
                obj.interface = obj.interface(1);
            end            
            obj.status = 'interfaced';
        end
        function create_device(obj)
            if(isempty(obj.interface));error('No Interface');end;
            if(isempty(obj.mdd));error('No MDD Link');end;
            if(~exist(obj.mdd,'file'));error('No MDD File');end;
            obj.device = instrfind('Type', 'scope', 'DriverName', obj.mdd);         
            if isempty(obj.device)
              % Create a device object if it does not exist
                obj.device = icdevice(obj.mdd, obj.interface);
            else
                % otherwise use the object that was found.
                fclose(obj.device);
                obj.device = obj.device(1);
            end 
            obj.status = 'disconnected';
        end
        function bool = isconnected(obj)
            if(isempty(obj.device));bool = 0;return;end;
            if strcmp(obj.device.status,'open')
                bool = 1;
            else
                bool = 0;
            end
        end
    end
end

