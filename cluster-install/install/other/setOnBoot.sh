source $SCRIPTPATH/setenv.sh
#!/bin/bash
file="/etc/sysconfig/network-scripts/ifcfg-$1"
new=$2	
onBoot=`awk -F = '/ONBOOT/ {print $2}' $file`
if [ "$onBoot" != "" ]
then
	sed -i 's/ONBOOT='$onBoot'/ONBOOT='$new'/' $file
else
	echo "ONBOOT=$new" >> $file
fi
