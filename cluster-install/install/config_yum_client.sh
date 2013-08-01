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

scp -q /etc/yum.repos.d/edh.repo root@$client:/etc/yum.repos.d/
scp -q /etc/yum.repos.d/os.repo root@$client:/etc/yum.repos.d/

ssh root@$client '
umask 022
yum clean all;yum list >/dev/null
'

if [[ $? -ne 0 ]]; then
    exit 1
fi
