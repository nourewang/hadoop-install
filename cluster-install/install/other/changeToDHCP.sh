#!/bin/bash

source $SCRIPTPATH/setenv.sh

file="/etc/sysconfig/network-scripts/ifcfg-$1"
bootProto=`awk -F = '/BOOTPROTO/ {print $2}' $file`
if [ $bootProto != "dhcp" ]
then
	sed -i 's/BOOTPROTO='$bootProto'/BOOTPROTO=dhcp/' $file
	sed -i '/IPADDR/'d $file
	sed -i '/NETMASK/'d $file
	sed -i '/GATEWAY/'d $file
fi
