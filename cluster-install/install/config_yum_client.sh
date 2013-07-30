#!/bin/sh

. /etc/edh/installation.conf

# $1 for client ip or hostname; $2 for server ip or hostname
if [ $# != 3  -a $# != 2 ]; then 
	echo "USAGE:  
	./config_yum_client.sh CLIENT_ADDRESS  SERVER_ADDRESS
	"; exit 1; 
fi

client=$1
server="$2"

script_dir=`dirname $0`
hostname=`hostname`

clean_repofile="yes"
generate_os_repofile="no"
ospg_version="$OS_DISTRIBUTOR_ALIAS$OS_RELEASE_ALIAS"

if [ -d "$FTP_DIR/os_related/$ospg_version" ]; then
	has_ospg="yes"
else
	had_ospg="no"
fi

if [ -f /usr/lib/intelcloud/binded_ip.csv ]; then
	clean_repofile=`cat /usr/lib/intelcloud/binded_ip.csv | grep "^clean_${REPO_BIN}_repofile" | awk -F ',' '{print $2}'`
	os_repo_url=`cat /usr/lib/intelcloud/binded_ip.csv | grep "^remote_os_repo" | awk -F ',' '{print $2}'`
	os_repo_proxy=`cat /usr/lib/intelcloud/binded_ip.csv | grep "^os_repo_proxy," | awk -F ',' '{print $2}'`
	os_repo_proxy_user=`cat /usr/lib/intelcloud/binded_ip.csv | grep "^os_repo_proxy_user," | awk -F ',' '{print $2}'`
	os_repo_proxy_password=`cat /usr/lib/intelcloud/binded_ip.csv | grep "^os_repo_proxy_password," | awk -F ',' '{print $2}'`
	generate_os_repofile=`cat /usr/lib/intelcloud/binded_ip.csv | grep "^generate_os_repofile," | awk -F ',' '{print $2}'`
fi

# edit yum configuration file on client
ssh root@$client '
umask 022
yum_config_log='$IM_CONFIG_LOGDIR'/node-config.log

if [ ! -d '$IM_CONFIG_LOGDIR' ]; then
	mkdir '$IM_CONFIG_LOGDIR' -p
fi

echo -e "Starting configuring '$REPO_BIN' client at `date`\n\
[IM_CONFIG_PROCESS]: Appointing '$REPO_BIN' repository\n\
[IM_CONFIG_INFO]: EDH repository server is '$server'.\n\
[IM_CONFIG_INFO]: Configuring '$REPO_BIN' repository for '$client' ...." | tee -a $yum_config_log

if [ -d '$REPO_CONFDIR' ]; then
	cd '$REPO_CONFDIR'
else
	echo -e "[IM_CONFIG_ERROR]: Can not find '$REPO_CONFDIR'" | tee -a $yum_config_log
	exit 1
fi

if [ "'$clean_repofile'" != "no" ]; then
	for file in `ls *.repo 2>/dev/null`
	do
		mv -f $file $file.bak
		echo -e "[IM_CONFIG_INFO]: Backup $file.repo to $file.repo.bak" | tee -a $yum_config_log
	done
else
	rm -rf *.repo*
fi

if [ "x'$os_repo_url'" == "x" ]; then
	if [ "'$generate_os_repofile'" != "no" ]; then
		[ "'$REPO_BIN'" == "yum" ] && url="ftp://'$server'/pub/os"
		[ "'$REPO_BIN'" == "zypper" ] && url="ftp://'$server'/os"
	fi
else
	url='$os_repo_url'
fi

if [ "x$url" != "x" ]; then
	if [ "'$REPO_BIN'" == "yum" ]; then
		echo -e "[os]\nname = Linux OS Packages\nbaseurl = $url\ngpgcheck = 0" > os.repo
		if [ "x'$os_repo_url'" == "x" ]; then
			echo "proxy = _none_" >> os.repo
		else
			[ ! -z "'$os_repo_proxy'" ] && echo "proxy = '$os_repo_proxy'" >> os.repo
	        	[ ! -z "'$os_repo_proxy_user'" ] && echo "proxy_username = '$os_repo_proxy_user'" >> os.repo
	        	[ ! -z "'$os_repo_proxy_password'" ] && echo "proxy_password = '$os_repo_proxy_password'" >> os.repo
		fi
	elif [ "'$REPO_BIN'" == "zypper" ]; then
		zypper clean > /dev/null 2>&1
		[ -f /etc/zypp/repos.d/os.repo ] && rm -f /etc/zypp/repos.d/os.repo
		zypper addrepo $url os > /dev/null
		zypper modifyrepo -p 70 os > /dev/null
		echo "gpgcheck=0" >> /etc/zypp/repos.d/os.repo
	fi

	echo -e "[IM_CONFIG_INFO]: Set os repo baseurl to $url" | tee -a $yum_config_log
fi

os_version="'$OS_DISTRIBUTOR_ALIAS$OS_RELEASE_ALIAS'"
if [ "'$REPO_BIN'" == "yum" ]; then
	echo -e "[edh]\nname = edh and related packages\nbaseurl = ftp://'$server'/pub/edh\nproxy = _none_\ngpgcheck =0\n" > edh.repo
	echo -e "[IM_CONFIG_INFO]: Set edh repo baseurl to ftp://'$server'/pub/edh" | tee -a $yum_config_log
        echo -e "[IM_CONFIG_INFO]: Clean yum cache" | tee -a $yum_config_log
        yum clean  all -y 2>&1

elif [ "'$REPO_BIN'" == "zypper" ]; then
	[ -f /etc/zypp/repos.d/edh.repo ] && rm -f /etc/zypp/repos.d/edh.repo
	zypper addrepo ftp://'$server'/pub/edh edh > /dev/null
	zypper modifyrepo -p 70 edh > /dev/null
	echo "gpgcheck=0" >> /etc/zypp/repos.d/edh.repo
	zypper --no-gpg-checks refresh > /dev/null
	echo -e "[IM_CONFIG_INFO]: Set edh repo baseurl to ftp://'$server'/edh" | tee -a $yum_config_log
fi
if [ "'$has_ospg'" == "yes" ]; then
	if [ "'$REPO_BIN'" == "yum" ]; then
	    echo -e "[ospkg]\nname = related os packages\nbaseurl = ftp://'$server'/pub/os_related/$os_version\nproxy = _none_\ngpgcheck = 0\n" >> edh.repo
	    echo -e "[IM_CONFIG_INFO]: Set ospkg repo baseurl to ftp://'$server'/pub/os_related/$os_version" | tee -a $yum_config_log
	    echo -e "[IM_CONFIG_INFO]: Clean yum cache" | tee -a $yum_config_log
            yum clean  all -y 2>&1

	elif [ "'$REPO_BIN'" == "zypper" ]; then
            [ -f /etc/zypp/repos.d/ospkg.repo ] && rm -f /etc/zypp/repos.d/ospkg.repo
            zypper addrepo ftp://'$server'/os_related/$os_version ospkg > /dev/null
            zypper modifyrepo -p 70 ospkg > /dev/null
            echo "gpgcheck=0" >> /etc/zypp/repos.d/ospkg.repo
            zypper --no-gpg-checks refresh > /dev/null
	    echo -e "[IM_CONFIG_INFO]: Set ospkg repo baseurl to ftp://'$server'/os_related/$os_version" | tee -a $yum_config_log
            echo -e "[IM_CONFIG_INFO]:Clean zypper cache" | tee -a $yum_config_log
            zypper clean 2>&1

	fi
fi

echo -e "[IM_CONFIG_PROCESS]: Configure '$REPO_BIN' for '$client' successfully!
Stopping configuring '$REPO_BIN' client at `date`
" | tee -a $yum_config_log
'

if [[ $? -ne 0 ]]; then
    exit 1
fi
