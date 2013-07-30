#!/bin/sh

. /etc/edh/installation.conf

# $1 for client ip or hostname; $2 for server FQDN, $3 for server ip
if [ $# != 3  -a $# != 2 ]; then 
	echo "USAGE: 
	./config_client.sh CLIENT SERVER_NAME SERVER_IP   #use /etc/hosts to manage hostname resolving
	./config_client.sh CLIENT SERVER_NAME             #use existing DNS server to manage hostname resolving
	"; exit 1; 
fi

client=$1
server=$2
server_ip=$3

script_dir=`dirname $0`
export client_config_log=$IM_CONFIG_LOGDIR/node-config.log

#server_hostname=`ssh root@$server hostname`
#client_hostname=`ssh root@$client hostname`
#client_hostname_lc=`tr A-Z a-z <<< $client_hostname`

# ========= Executed on every node ========== 
ssh root@$client '
umask 022

function stop_networkmanager {
    if rpm -qa | grep -e "NetworkManager-[0..9].*" >/dev/null 2>&1; then
        if [ -f /etc/sysconfig/network/config ] ; then
            NETWORKMANAGER_BIN=/usr/sbin/NetworkManager
            if checkproc $NETWORKMANAGER_BIN > /dev/null 2>&1 ; then
                echo "[IM_CONFIG_PROCESS]: Disable NetworkManager..."
                sed -i "/NETWORKMANAGER/ s/yes/no/g" /etc/sysconfig/network/config
                service network restart 2>&1
            else
                sed -i "/NETWORKMANAGER/ s/yes/no/g" /etc/sysconfig/network/config
            fi
        else
            if service NetworkManager status >/dev/null 2>&1 ; then
                echo "[IM_CONFIG_PROCESS]: Stop NetworkManager..."
                service NetworkManager stop 2>&1
            fi
            chkconfig --level 12345 NetworkManager off
        fi
    fi
}

if [ ! -d '$IM_CONFIG_LOGDIR' ]; then
        mkdir '$IM_CONFIG_LOGDIR' -p
fi

echo "Starting configuring puppet client at `date`" >> '$client_config_log'

echo "[IM_CONFIG_PROCESS]: Installing JDK" | tee -a '$client_config_log'
'$REPO_BIN' clean '$REPO_CLEANALL_OPT' 2>&1 | tee -a '$client_config_log'


#install jdk
execmsg=`'$REPO_BIN' '$REPO_YES_OPT' -q install jdk 2>&1`
if [ "$?" == "0" ]; then
    echo "[IM_CONFIG_PROCESS]: Finish installing JDK" | tee -a '$client_config_log'
else
    echo "[IM_CONFIG_ERROR]: $execmsg" | tee -a '$client_config_log'
    exit 1
fi
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


stop_networkmanager >> '$client_config_log'

exit'

if [ $? == 1 ]; then 
	exit 1
fi

# ========= Executed on client nodes ========== 
if [ "x$server_ip" != "x" ]; then
	ssh root@$client '
umask 022
sed -i "s:127\.0\.0\.1.*:127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4:g" /etc/hosts
sed -i "/.*'$server'.*/d" /etc/hosts
echo "'$server_ip'  '$server'" >> /etc/hosts
exit'
fi

$script_dir/config_ntp_client.sh $client $server



