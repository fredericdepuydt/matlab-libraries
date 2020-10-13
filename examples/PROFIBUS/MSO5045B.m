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

% For the MSO5054B a waveform file of type .wfm is required
% using scope class -> wfmread function -> file and verbosity as parameters
%   file = "waveform_CH1.wfm"
%   verbose = -1 -> Full depth verbosity (Output everything to CLI)
objMSO5045B = scope.wfmread('MSO5045B/waveform_CH1.wfm',-1);

% Both functions return an object of class scope

%% PLOTTING SCOPE OBJECT
CH1 = objMSO5045B.channels(1);
X = objMSO5045B.time;
Y = objMSO5045B.values(CH1);

figure(1);
plt(X,Y);

%% CREATING PROFIBUS (Currently UART Class) object
objUART = uart.decode(objMSO5045B, 1, 1500000, -1);

%% PLOT UART OBJECT
figure();
objUART.plot(0,0,1)
axis([objUART(1).time objUART(end).time_end -3 3]);

%% TABLE WITH PACKETS
figure();
objUART.table()


