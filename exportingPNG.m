
%% PRINT TO IMAGE
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 9])
print('-dpng','KleineScoop 1600x900 res 400','-r400');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 9])
print('-dpng','KleineScoop 1600x900 res 100','-r100');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 12 9])
print('-dpng','KleineScoop 1200x900','-r100');

%% TRANSPARENT
set(gcf, 'Position', get(0,'Screensize')/2);
export_fig('Packet Times (PB vs PN)','-dpng','-r100','-transparent', '-nocrop')
title('');
export_fig('Packet Times (PB vs PN)(No Title)','-dpng','-r100','-transparent', '-nocrop');