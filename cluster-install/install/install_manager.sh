#!/bin/sh

if [ "$#" != "0" ]; then
    echo "USAGE: 
    ./install_manager.sh"
    exit 1
fi

umask 022
script_dir=`dirname $0`
dns_alt_names=`hostname`
export LD_LIBRARY_PATH=$path:$LD_LIBRARY_PATH

echo -e "\nInstall Embrace(R) Distribution for Apache Hadoop* Software...\n"
echo -e "\nHostname is $dns_alt_names, Time is `date +'%F %T'`, TimeZone is `date +'%Z %:z'`\n"


. /etc/edh/installation.conf

sh config_yum_manager.sh $dns_alt_names
sh cleanrepo.sh

echo -e "\nInstalling jdk,expect,ntp,nagios,ssh and other required packages ..."
$REPO_BIN $REPO_YES_OPT -q install jdk expect $SSH_PKGS ntp nagios nagios-plugins
if ! rpm -q jdk expect $SSH_PKGS ntp>/dev/null ; then
    exit 1
fi


# set JAVA_HOME and PATH
if [ -f /root/.bashrc ] ; then
    sed -i '/^export[[:space:]]\{1,\}JAVA_HOME[[:space:]]\{0,\}=/d' /root/.bashrc
    sed -i '/^export[[:space:]]\{1,\}CLASSPATH[[:space:]]\{0,\}=/d' /root/.bashrc
    sed -i '/^export[[:space:]]\{1,\}PATH[[:space:]]\{0,\}=/d' /root/.bashrc
fi
echo "" >>/root/.bashrc
echo "export JAVA_HOME=/usr/java/latest" >>/root/.bashrc
echo "export CLASSPATH=.:\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar">>/root/.bashrc
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /root/.bashrc
source /root/.bashrc

if ( hostname -f >/dev/null 2>&1 ) && [ "`hostname -f`" != "$dns_alt_names" ]; then
    dns_alt_names="$dns_alt_names,`hostname -f`"
fi

#set up ssh keys
yes|ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ""
[ ! -d /root/.ssh ] && ( mkdir /root/.ssh ) && ( chmod 700 /root/.ssh )

sh $script_dir/config_ssh_local.sh

#configure ntp server and start ntpd service
\cp /etc/edh/ntp.conf /etc/ntp.conf
sed -i "/^driftfile/ s:^driftfile.*:driftfile $NTP_CONF_DRIFTFILE:g" /etc/ntp.conf
if service $NTP_BIN status >/dev/null 2>&1; then
    service $NTP_BIN stop
fi
service $NTP_BIN start

echo -e "\nInstall Embrace(R) Distribution for Apache Hadoop* Software successfully\n"

