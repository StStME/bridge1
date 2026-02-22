raspberry pi uses NetworkMangaer instead of wpa-supplicant. 

so I have to adapt the debian example https://wiki.debian.org/BridgeNetworkConnectionsProxyArp to work with NetworkManager.

from debian.org 
I need to install: sudo apt-get install parprouted dhcp-helper avahi-daemon

need to set net.ipv4.ip_forward=1 in /etc/sysctl.d/local.conf

enable dhcp relay in /etc/default/dhcp-helper:

```
# /etc/default/dhcp-helper
DHCPHELPER_OPTS="-b wlan0 -i eth0"
```

and enable the mDNS relaying: 
/etc/avahi/avahi-daemon.conf 



From: 
https://askubuntu.com/questions/1111652/network-manager-script-when-interface-up

I created the [post-up.sh](./post-up.sh) and [post-down.sh](./post-down.sh) scripts into /etc/NetworkManager/dispatcher.d/

In order for NetworkManager to execute them, they need ofc execution permission (chmod +x) but also they must be owned by root: chown root post-up/down.sh. 

Now it will work until the Network Manager will try to connect via the eht0 interface to the wired connection. This must be disabled 

needed to disable eth0-netplan config because it would interfere with the arp bridge: 

https://askubuntu.com/questions/1445221/permanently-disable-network-interface-in-ubuntu-22-04 -> settion activation-mode: off in the netplan yml did not work unfortunately but using nmcli and modifying the connection (see below did work like a charm). Disabling autoconnect for the interface did also not work.  

that did not help. 

Trying: 
nmcli device set <interface> autoconnect yes

did not work (or was not sufficient?)

well, executing `nmcli -f name,autoconnect con show` showed that "Wired connection 1" which is asssigned to eth0 was still autoconnecting so `sudo nmcli c modify "Wired connection 1" connection.autoconnect no` disabled it. lets restart and see if that helped. 
