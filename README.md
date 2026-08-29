# WiFi-to-Ethernet Bridge


```mermaid
%% WiFi-to-Ethernet Bridge Diagram
graph LR
    R[Router] --> A
    A[WiFi Access Point] -- Wireless --> B[Raspberry Pi - Bridge]
    B -- Ethernet --> C[Non-WiFi / Wired Device]
    A -- Wireless -->  D[Other WiFi Devices]
    R --- E[Other Wired Devices]
    B:::bridge
    classDef bridge stroke:#333,stroke-width:2px;
```

This project aims to create a transparent WiFi-to-Ethernet bridge for your home network. With this setup, you can easily connect devices (?) that lack WiFi support to your network without running cables everywhere or relying on technologies like D-LAN.

**Note:** Raspberry Pi uses NetworkManager instead of wpa-supplicant, so the [standard Debian instructions](https://wiki.debian.org/BridgeNetworkConnectionsProxyArp) must be adapted.

### Required Packages

Install the following packages:
```
sudo apt-get install parprouted dhcp-helper avahi-daemon
```

### System Configuration

Enable IP forwarding by adding the following to `/etc/sysctl.d/local.conf`:
```
net.ipv4.ip_forward=1
```

Configure DHCP relay in `/etc/default/dhcp-helper`:
```
DHCPHELPER_OPTS="-b wlan0 -i eth0"
```

Enable mDNS relaying by editing `/etc/avahi/avahi-daemon.conf`.

### NetworkManager Dispatcher Scripts

Referencing [this AskUbuntu post](https://askubuntu.com/questions/1111652/network-manager-script-when-interface-up), create `post-up.sh` and `post-down.sh` scripts in `/etc/NetworkManager/dispatcher.d/`.

Make sure both scripts are executable and owned by root:
```
chmod +x post-up.sh post-down.sh
chown root post-up.sh post-down.sh
```

### Disabling Wired Connection Autoconnect

NetworkManager may attempt to connect via `eth0`, which interferes with the ARP bridge. Disabling the netplan configuration for `eth0` (e.g., setting `activation-mode: off` in the YAML) may not work. Disabling autoconnect via NetworkManager is more reliable.

Check autoconnect status:
```
nmcli -f name,autoconnect con show
```
If "Wired connection 1" (assigned to `eth0`) is still set to autoconnect, disable it:
```
sudo nmcli c modify "Wired connection 1" connection.autoconnect no
```
Restart the system to apply changes.

### References

- [Debian ARP Bridge Example](https://wiki.debian.org/BridgeNetworkConnectionsProxyArp)
- [AskUbuntu: NetworkManager Dispatcher Scripts](https://askubuntu.com/questions/1111652/network-manager-script-when-interface-up)
- [AskUbuntu: Disabling Network Interface](https://askubuntu.com/questions/1445221/permanently-disable-network-interface-in-ubuntu-22-04)

## Practical Learnings for AirPlay and Wired Target Devices

### Guidance Learnings

For wired target devices behind the bridge, a static IP configuration on the target device is more reliable than DHCP. The key persistent setting is therefore a direct route from the Pi to the target device via `eth0`.

Recommended entry in `/etc/NetworkManager/dispatcher.d/post-up.sh`:

```bash
ip route replace 192.0.2.201 dev eth0 scope link metric 50
```

The address `192.0.2.201` is a documentation address and must be adapted to your local subnet.

### Notes for Potential Further Improvements

If AirPlay is visible but streaming does not start or immediately drops, the following additional measures may help.

1. Explicitly set proxy ARP and forwarding:

```bash
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.eth0.proxy_arp=1
sysctl -w net.ipv4.conf.wlan0.proxy_arp=1
```

2. Optionally set a dummy IP on the Pi cable interface:

```bash
ip addr add 192.0.2.254/24 dev eth0 2>/dev/null
```

Again, `192.0.2.x` is only a documentation example range.

### Debugging Cheatsheet

#### 1. Check ARP visibility of the target device

```bash
arp -an | grep <target-device-ip>
```

If `<incomplete>` appears: check cable/link state or restart the target device.

#### 2. Observe mDNS/AirPlay traffic

```bash
sudo tcpdump -i any port 5353 -n
```

#### 3. Verify routing

```bash
ip route show
```

The target route via `eth0` must be present.

#### 4. Check service status

```bash
sudo systemctl status avahi-daemon
sudo systemctl status dhcp-helper
```

Both services should be `active (running)`.
