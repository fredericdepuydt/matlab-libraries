%  
%  This function displays graph of measurements taken
% 
%  showPackets(ethObjArr)
% 
%  ethObjArr is a mandatory field. It is a cell array of eth objects.
% 
%  showPackets(__, 'PropName', PropValue)
% 
%  Properties:
% 
%  'packetNumRange', measurementNum, time_vector - Align axes by user defined packet numbers
%  
%  'time', [leftTimeBorder, rightTimeBorder] - Show defined timerange(it counts from the earliest measerument)
% 
%  'colors', colorVector - Set tick colors, colorVector should have the same cell size as passed ethObjArr
% 
% 
%  Examples:
% 
%  showPackets({etharr1,etharr2},'time',[8.05,8.22]) 
%  showPackets({etharr1,etharr2},'time',[8.05,8.22], 'colors', {[0 1 1], [0 1 0]})     
%
