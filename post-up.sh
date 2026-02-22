#!/usr/bin/env bash


interface=$1
event=$2

if [[ $interface != "wlan0" ]] || [[ $event != "up" ]]
then
  return 0
fi
sh -c "/usr/sbin/parprouted eth0 wlan0"
  # clone the dhcp-allocated IP to eth0 so dhcp-helper will relay for the correct subnet
sh -c "/sbin/ip addr add $(/sbin/ip addr show wlan0 | perl -wne 'm|^\s+inet (.*)/| && print $1')/32 dev eth0"