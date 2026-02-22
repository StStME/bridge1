#!/usr/bin/env bash

interface=$1
event=$2

if [[ $interface != "wlan0" ]] || [[ $event != "down" ]]
then
  return 0
fi

sh -c "/usr/bin/killall /usr/sbin/parprouted"
sh -c "/sbin/ifdown eth0"