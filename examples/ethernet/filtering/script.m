close all;

%% inlezen isf files
if(~exist('first','var') || first)
    objEth = eth.pcapread('PROFINET - Startup.pcapng');
    first = false;
end

%% Show information
objEth.addresses();
objEth.ethertypes();

%% Filtering examples - usage: eth.filter(filterstr, verbose);
objEth_ARP = objEth.filter('arp',-1);   % ARP
objEth_IP = objEth.filter('ip',-1);     % IP
objEth_LLDP = objEth.filter('lldp',-1); % LLDP
%objEth_UDP = objEth.filter('udp',-1);  % UDP (Currently not supported)
%objEth_TCP = objEth.filter('tcp',-1);  % TCP (Currently not supported)

%objEth_PN_DCP = objEth.filter('pn_dcp',-1); % PN_DCP (Currently not supported)

objEth_0806 = objEth.filter('eth.type == 0x0806',-1); % ARP
objEth_0800 = objEth.filter('eth.type == 0x0800',-1); % IP
objEth_88CC = objEth.filter('eth.type == 0x88CC',-1); % LLDP

objEth_IO_C_to_D = objEth.filter('eth.src == 00:0E:8C:FA:E1:14',-1); % IO-Controller to IO-Devices
objEth_IO_D_to_C = objEth.filter('eth.dst == 00:0E:8C:FA:E1:14',-1); % IO-Devices to IO-Controller

objEth_Broadcast = objEth.filter('eth.dst==FF:FF:FF:FF:FF:FF',-1);      % PN Multicast
objEth_PN_Multicast = objEth.filter('eth.dst==01:0E:CF:00:00:00',-1);   % PN Multicast
objEth_LLDP_Multicast = objEth.filter('eth.dst==01:80:C2:00:00:0E',-1); % LLDP Multicast

%% Filtering with OR AND or NOT
objEth.filter('not arp',-1);
objEth.filter('not arp and not ip',-1);
objEth.filter('arp || lldp',-1);
objEth.filter('arp or not lldp',-1);
objEth.filter('ip and eth.dst == 00:0E:8C:FA:E1:14',-1);
objEth.filter('(arp or ip) and eth.dst == 00:0E:8C:FA:E1:14',-1);
objEth.filter('!eth.addr == 00:0E:8C:FA:E1:14',-1);
objEth.filter('eth.addr != 00:0E:8C:FA:E1:14',-1);