source $SCRIPTPATH/setenv.sh
#!/bin/bash
ethList=`ifconfig -a|grep -E 'eth|bond' | awk '{ print $1}'`
#echo $ethList
for eth in $ethList
do
	ethMAC=`ifconfig $eth | grep 'HWaddr'| awk '{print $5}'`
	ethIP=`ifconfig $eth | grep 'inet addr'| awk '{print $2}'| awk -F : '{print $2}'`	
	ethMask=""	
	ethGateWay=""
	ethBcast=""
	if [ "$ethIP" != "" ]
	then
		ethMask=`ifconfig $eth| grep 'Mask'| awk '{print $4}'| awk -F : '{print $2}'`
		ethBcast=`ifconfig $eth| grep 'Bcast'| awk '{print $3}'| awk -F : '{print $2}'`
		ethGateWay=`route -n | grep .*UG.*$eth | awk '{print $2}'`
	fi
	ethOnBoot=`awk -F = '/ONBOOT/ {print $2}' "/etc/sysconfig/network-scripts/ifcfg-$eth"`
	ethBootProto=`awk -F = '/BOOTPROTO/ {print $2}' "/etc/sysconfig/network-scripts/ifcfg-$eth"`
	echo $eth-$ethMAC-$ethIP-$ethMask-$ethBcast-$ethGateWay-$ethOnBoot-$ethBootProto
done
