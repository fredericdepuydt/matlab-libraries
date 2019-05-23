%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %%                            UART CLASS                              %%
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %                                                                      %
%    %    Author: Frederic Depuydt                                          %
%    %    Company: KU Leuven                                                %
%    %    Contact: frederic.depuydt@kuleuven.be; f.depuydt@outlook.com      %
%    %    Version: 1.3                                                      %
%    %                                                                      %
%    %    An UART class to analyse PROFIBUS DP packets                      %
%    %    Readable files: ptd (ProfiTrace)                                  %
%    %    Usable with: Scope object                                         %
%    %                                                                      %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %        FUNCTIONS (static)                 *Object creation*          %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %                                                                      %
%    %    usage: objUart = uart.function(var1, var2, ...)                   %
%    %                                                                      %
%    %    ptdread(                Importing a ProfiTrace PTD file           %
%    %        file,                   Filename + extension as String        %
%    %        verbose)                Integer to enable verbose mode        %
%    %                                                                      %
%    %    decode(                 Decoding a Scope object                   %
%    %        objScope,               The Scope object to decode            %
%    %        channel,                The channel to be decoded             %
%    %        baudrate,               Baudrate to decode at                 %
%    %        verbose)                Integer to enable verbose mode        %
%    %                                                                      %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %        FUNCTIONS (non-static)                                        %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %                                                                      %
%    %    usage: result = objUart.function(var1, var2, ...)                 %
%    %    note: most functions do not alter the original uart object,       %
%    %          but return a new object with the function results           %
%    %                                                                      %
%    %    values(                 Returning the values of a channel         %
%    %        channels)               Array of strings refering to channels %
%    %            returns: matrix of the requested values                   %
%    %                                                                      %
%    %    table(                  Shows a ProfiTrace style table of packets %
%    %        fig)                    Figure handle (optional)              %
%    %            returns: [fig table]    Figure handler and table handler  %
%    %                                                                      %
%    %    plot(                   Plot packets as ProfiTrace styled colors  %
%    %        offset_x,                                                     %
%    %        offset_y,                                                     %
%    %        lineWidth)                                                    %
%    %            returns: nothing                                          %
%    %                                                                      %
%    %    ptdwrite(               Exporting to a ProfiTrace PTD file        %
%    %        file,                   Filename + extension as String        %
%    %        verbose)                Integer to enable verbose mode        %
%    %            returns: nothing                                          %
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
%        doc uart
% 
% 
%
