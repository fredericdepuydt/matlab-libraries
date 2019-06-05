close all;

%% inlezen isf files
if(~exist('first','var') || first)
    objEth = eth.pcapread('PROFINET - Startup.pcapng');
    first = false;
end

%% Show information
objEth.addresses();
objEth.ethertypes();

%% Filtering examples
objEth_ARP = objEth.filter('arp');   % ARP
objEth_IP = objEth.filter('ip');     % IP
objEth_LLDP = objEth.filter('lldp'); % LLDP
%objEth_UDP = objEth.filter('udp');  % UDP (Currently not supported)
%objEth_TCP = objEth.filter('tcp');  % TCP (Currently not supported)

%objEth_PN_DCP = objEth.filter('pn_dcp'); % PN_DCP (Currently not supported)

objEth_0806 = objEth.filter('eth.type == 0x0806'); % ARP
objEth_0800 = objEth.filter('eth.type == 0x0800'); % IP
objEth_88CC = objEth.filter('eth.type == 0x88CC'); % LLDP

objEth_cpu315f124 = objEth.filter('eth.src == 00:0E:8C:FA:E1:14'); % IO-Controller
objEth_et200sp174 = objEth.filter('eth.src == 00:0E:8C:FA:E1:14'); % IO-Device

objEth_Broadcast = objEth.filter('eth.dst==FF:FF:FF:FF:FF:FF');      % PN Multicast
objEth_PN_Multicast = objEth.filter('eth.dst==01:0E:CF:00:00:00');   % PN Multicast
objEth_LLDP_Multicast = objEth.filter('eth.dst==01:80:C2:00:00:0E'); % LLDP Multicast

