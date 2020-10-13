%% LIBRARIES
% Manually add libraries to path
% Preferrably using Git or by downloading a released version
%
% Author: Frederic Depuydt <frederic.depuydt@outlook.com>
% Url: https://github.com/fredericdepuydt/matlab-libraries/releases
% Command: git clone https://github.com/fredericdepuydt/matlab-libraries.git libraries

%% CLEAN WORKSPACE AND FIGURES
clear all;
close all;

%% CREATING SCOPE OBJECTS FROM WAVEFORM FILE

% For the DPO4054B a waveform file of type .isf is required
% using scope class -> isfread function -> file and verbosity as parameters
%   file = "tek0000CH1.isf"
%   verbose = -1 -> Full depth verbosity (Output everything to CLI)
objDPO4054B = scope.isfread("DPO4054B/tek0000CH1.isf", -1);

% Both functions return an object of class scope

%% PLOTTING SCOPE OBJECT
CH1 = objDPO4054B.channels(1);
X = objDPO4054B.time;
Y = objDPO4054B.values(CH1);

figure(1);
plt(X,Y);

%% CREATING PROFIBUS (Currently UART Class) object
objUART = uart.decode(objDPO4054B, 1, 1500000, -1);

%% PLOT UART OBJECT
figure();
objUART.plot(0,0,1)
axis([objUART(1).time objUART(end).time_end -3 3]);

%% TABLE WITH PACKETS
figure();
objUART.table()

%% EXPORT TO PROFITRACE
objUART.ptdwrite("test.ptd",-1);

%% IMPORT FROM PROFITRACE
newUART = uart.ptdread("test.ptd",-1);

%% FILTERING PROFIBUS PACKETS
SD1 = objUART.filter('SD1');
SD2 = objUART.filter('SD2');
SD3 = objUART.filter('SD3');
SD4 = objUART.filter('SD4');
SC = objUART.filter('SC');


SD2or4 = objUART.filter('SD2 OR SD4');

Master = objUART.filter('SA = 74');

Retries = objUART.filter('FC = 6D');





