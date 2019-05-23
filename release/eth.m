%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %%                          ETH PACKET CLASS                          %%
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %                                                                      %
%    %    Author: Frederic Depuydt                                          %
%    %    Company: KU Leuven                                                %
%    %    Contact: frederic.depuydt@kuleuven.be; f.depuydt@outlook.com      %
%    %    Version: 1.1                                                      %
%    %                                                                      %
%    %    An ETHERNET class to analyse packets from Wireshark               %
%    %    and some Tektronix Osciloscopes.                                  %
%    %                                                                      %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %        FUNCTIONS (static)                 *Object creation*          %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %                                                                      %
%    %    usage: objEth = eth.function(var1, var2, ...)                     %
%    %                                                                      %
%    %    csvread(                Reading an EVENT TABLE CSV file           %
%    %        file,                   Filename + extension as String        %
%    %        verbose)                Integer to enable verbose mode        %
%    %                                                                      %
%    %    pcapread(               Reading a Wireshark PCAP file             %
%    %        file,                   Filename + extension as String        %
%    %        verbose,                Integer to enable verbose mode        %
%    %        captureFilter)          Wireshark filter as String            %
%    %                                                                      %
%    %    scoperead(              Reading a Scope object                    %
%    %        objScope,               Scope object to read                  %
%    %        verbose)                Integer to enable verbose mode        %
%    %                                                                      %
%    %    scoperead(              Reading a Scope object                    %
%    %        objScope,               Scope object to read                  %
%    %        parameter,              A certain parameter                   %
%    %        value,                  Value for the parameter               %
%    %        ...)                Possible parameters:                      %
%    %                                  'verbose', 'threshold',             %
%    %                                  'cut_off_frequency'                 %
%    %                                                                      %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %        FUNCTIONS (non-static)                                        %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %                                                                      %
%    %    usage: objEth.function(var1, var2, ...)                           %
%    %                                                                      %
%    %    plot(                   Plotting Ethernet Packets in Time         %
%    %        offset_x,                                                     %
%    %        offset_y,                                                     %
%    %        lineWidth,                                                    %
%    %        line_color)                                                   %
%    %                                                                      %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %                                                                      %
%    %    VERBOSE MODE: (default=-1)                                        %
%    %        all static functions check for a verbose variable             %
%    %        to enable or disable display output to the console            %
%    %                                                                      %
%    %    verbose ==  0;  % Display output disabled                         %
%    %    verbose == -1;  % Display output enabled for all nested functions %
%    %    verbose ==  x;  % Display output enabled for x nested functions   %
%    %                                                                      %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     Reference page in Doc Center
%        doc eth
% 
% 
%
