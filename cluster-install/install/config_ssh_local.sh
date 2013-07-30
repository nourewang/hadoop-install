#!/bin/sh

umask 022

function addline {
    line=$1
    file=$2
    tempstr=`grep "$line" $file  2>/dev/null`
    if [ "$tempstr" == "" ]
    then
        echo "$line" >>$file
    fi
}

if [ ! -d /root/.ssh ]; then
    mkdir /root/.ssh
    chmod 700 /root/.ssh
fi

#ssh config
addline "StrictHostKeyChecking no" /root/.ssh/config
addline "UserKnownHostsFile /dev/null" /root/.ssh/config
addline "LogLevel ERROR" /root/.ssh/config

# stop firewalls
[ -f /etc/init.d/iptables ] && FIREWALL="iptables"
[ -f /etc/init.d/SuSEfirewall2_setup ] && FIREWALL="SuSEfirewall2_setup"
[ -f /etc/init.d/boot.apparmor ] && SELINUX="boot.apparmor"
[ -f /usr/sbin/setenforce ] && SELINUX="selinux"
service $FIREWALL stop >/dev/null 2>&1
chkconfig $FIREWALL off > /dev/null 2>&1
if [ $SELINUX == "selinux" ]; then
    sed -i "s/.*SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config 
    setenforce 0  >/dev/null 2>&1
elif [ $SELINUX == "boot.apparmor" ]; then
    service boot.apparmor stop >/dev/null 2>&1
    chkconfig boot.apparmor off > /dev/null 2>&1
fi

#set global file limit
rst=`grep "^fs.file-max" /etc/sysctl.conf`
if [ "x$rst" = "x" ]
then
	echo "fs.file-max = 727680" >> /etc/sysctl.conf || exit $?
else
	sed -i "s:^fs.file-max.*:fs.file-max = 727680:g" /etc/sysctl.conf
fi

addline "*	soft	nofile	327680" /etc/security/limits.conf
addline "*	hard	nofile	327680" /etc/security/limits.conf

for user in hdfs mapred hbase zookeeper hive root
do
    addline "$user	soft	nproc	131072" /etc/security/limits.conf
    addline "$user	hard	nproc	131072" /etc/security/limits.conf
done

chmod 1777 /tmp
