#!/usr/bin/env bash

interface=$1
event=$2

if [[ $interface != "wlan0" ]] || [[ $event != "down" ]]
then
  exit 0
fi

/usr/bin/killall /usr/sbin/parprouted
/usr/bin/nmcli d down eth0