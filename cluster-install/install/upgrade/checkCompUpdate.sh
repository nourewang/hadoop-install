compName=$1

script_dir=`dirname $0`
. /etc/intelcloud/installation.conf

if [ "$OS_DISTRIBUTOR" == "sles" ]; then
  zypper clean -a 2>/dev/null 1>&2
  zypper refresh 2>/dev/null 1>&2
  compUpdates=`zypper list-updates | grep $compName*` 
  while read Line
  do
    #echo $Line
    repository=`echo $Line | awk -F '|' '{print $2}'`
    packageName=`echo $Line | awk -F '|' '{print $3}'`
    currentVersion=`echo $Line | awk -F '|' '{print $4}'`
    availableVersion=`echo $Line | awk -F '|' '{print $5}'`
    echo $packageName $availableVersion $repository
  done << EOF
  $compUpdates
EOF
else
  yum clean all 2>/dev/null 1>&2
  yum check-update | grep $compName* |grep idh
fi
