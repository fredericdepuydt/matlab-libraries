%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %%                             TEK CLASS                              %%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %                                                                      %
%   %    Author: Frederic Depuydt                                          %
%   %    Company: KU Leuven                                                %
%   %    Contact: frederic.depuydt@kuleuven.be; f.depuydt@outlook.com      %
%   %    Version: 1.1                                                      %
%   %                                                                      %
%   %    An Tek class for remote use of Tektronics Scopes                  %
%   %    Usable oscilloscopes: DPO4054B                                    %
%   %                                                                      %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %        FUNCTIONS (static)                 *Object creation*          %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %                                                                      %
%   %    objTek = tek(               Constructor                           %
%   %                model,              model name as string              %
%   %                ip_address,         IP address as string              %
%   %                port)               port as integer                   %
%   %                                                                      %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %        FUNCTIONS (non-static)                                        %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %                                                                      %
%   %    usage: result = objTek.function(var1, var2, ...)                  %
%   %                                                                      %
%   %    connect()               Open the connection to the oscilloscope   %
%   %                                                                      %
%   %    single()                Set oscilloscope in single shot mode      %
%   %                                                                      %
%   %    trigger()               Force a trigger on the oscilloscope       %
%   %                                                                      %
%   %    readwaveform(           Lowering the amount of sample rate        %
%   %        channels)               Channels to read as string array      %
%   %            returns: objScope with time and values of read channels   %             
%   %                                                                      %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %                                                                      %
%   %    VERBOSE MODE: (default=-1)                                        %
%   %        all static functions check for a verbose variable             %
%   %        to enable or disable display output to the console            %
%   %                                                                      %
%   %    verbose ==  0;  % Display output disabled                         %
%   %    verbose == -1;  % Display output enabled for all nested functions %
%   %    verbose ==  x;  % Display output enabled for x nested functions   %
%   %                                                                      %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%    Reference page in Doc Center
%       doc tek
%
%
