#!/bin/bash
source $SCRIPTPATH/setenv.sh
file="/etc/sysconfig/network-scripts/ifcfg-$1"
bootProto=`awk -F = '/BOOTPROTO/ {print $2}' $file`
sed -i 's/BOOTPROTO='$bootProto'/BOOTPROTO=none/' $file
sed -i '/IPADDR/'d $file
sed -i '/NETMASK/'d $file
sed -i '/GATEWAY/'d $file
echo IPADDR=$2 >> $file
echo NETMASK=$3 >> $file
echo GATEWAY=$4 >> $file
