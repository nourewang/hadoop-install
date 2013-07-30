# $1 hostname
# $2 compName
hostName=$1
compName=$2

script_dir=`dirname $0`
. /etc/intelcloud/installation.conf

if [ "$OS_DISTRIBUTOR" == "sles" ]; then
  ssh $hostName "
  zypper clean 2>/dev/null 1>&2
  zypper list-updates | grep $compName |grep idh
  "
else
  ssh $hostName "
  yum clean all 2>/dev/null 1>&2
  yum check-update | grep $compName |grep idh
  "
fi
