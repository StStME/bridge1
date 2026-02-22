#!/usr/bin/env bash


interface=$1
event=$2

# echo "post-up.sh started with if=$interface and ev=$event" >> /home/stefan/post-up.log

if [[ $interface != "wlan0" ]] || [[ $event != "up" ]]
then
  exit 0
fi
/usr/sbin/parprouted eth0 wlan0 &
  # clone the dhcp-allocated IP to eth0 so dhcp-helper will relay for the correct subnet
/sbin/ip addr add $(/sbin/ip addr show wlan0 | perl -wne 'm|^\s+inet (.*)/| && print $1')/32 dev eth0