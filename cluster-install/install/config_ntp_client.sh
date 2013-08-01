#!/bin/sh

. /etc/edh/installation.conf

if [ $# != 2 ]; then
        echo "USAGE: 
        ./config_ntp_client.sh CLIENT SERVER_NAME             #use existing DNS server to manage hostname resolving
        "; exit 1;
fi

ntp_client=$1
ntp_server=$2

script_dir=`dirname $0`
export config_log=$IM_CONFIG_LOGDIR/node-config.log

#set up client timezone
scp -q /etc/localtime root@$ntp_client:/etc/localtime
scp -q /etc/sysconfig/clock root@$ntp_client:/etc/sysconfig/clock

ssh root@$ntp_client '
    echo "[IM_CONFIG_PROCESS]: Synchronize time and timezone" | tee -a '$config_log'
    echo "[IM_CONFIG_INFO]: Waiting for '$ntp_client' update time to '$ntp_server'..." | tee -a '$config_log'

    # install ntp client
    echo "[IM_CONFIG_INFO]: Installing ntp" | tee -a '$config_log'
    execmsg=`'$REPO_BIN' '$REPO_YES_OPT' -q install ntp 2>&1`
    if [[ $? -ne 0 ]]; then
        echo "[IM_CONFIG_ERROR]: $execmsg" | tee -a '$config_log'
    else
        echo "[IM_CONFIG_INFO]: Finish Installing ntp" | tee -a '$config_log'
    fi

    if service '$NTP_BIN' status >/dev/null 2>&1; then
        service '$NTP_BIN' stop
    fi

    echo "[IM_CONFIG_INFO]: Synchronizing time with ntp server..." | tee -a '$config_log'
    waiting_time=9
    while ! '$NTP_UPDATE_CMD' '$ntp_server'  >> '$config_log' 2>&1
    do
        if [ $waiting_time -eq 0 ]; then
            echo "[IM_CONFIG_ERROR]: Please check whether the ntpd service is running on ntp server '$ntp_server'." | tee -a '$config_log'
	    exit 1
        fi

        mod=`expr $waiting_time % 3`
        if [[ $mod -eq 0 ]]; then
            echo "[IM_CONFIG_INFO]: ." | tee -a '$config_log'
        fi

        sleep 1
        let waiting_time=$waiting_time-1
    done

    for x in 1 2 3 4 5
    do
        echo -n "[IM_CONFIG_INFO]: " | tee -a '$config_log'
        '$NTP_UPDATE_CMD' '$ntp_server' | tee -a '$config_log'
        sleep 1
    done
    # write system clock to hardware clock.
    hwclock --systohc
'
