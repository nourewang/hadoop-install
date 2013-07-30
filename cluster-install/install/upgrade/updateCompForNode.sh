# $1 hsotname
# $2 compname
hostName=$1
compName=$2

script_dir=`dirname $0`
. /etc/intelcloud/installation.conf

if [ "$OS_DISTRIBUTOR" == "sles" ]; then
  ssh $hostName "
  zypper update $compName* -y
  "
else 
  ssh $hostName "
  yum update $compName* -y
  "
fi
