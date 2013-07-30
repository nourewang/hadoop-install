# $1 compName
compName=$1

script_dir=`dirname $0`
. /etc/intelcloud/installation.conf

if [ "$OS_DISTRIBUTOR" == "sles" ]; then
  zypper clean -a 2>/dev/null 1>&2
  zypper refresh 2>/dev/null 1>&2
  packageList=`zypper search $compName | grep $compName`
  while read Line
  do
    #echo $Line
    packageName=`echo $Line | awk -F '|' '{print $2}'`
    zypper info $packageName
  done << EOF
  $packageList
EOF
else
  yum clean all 2>/dev/null 1>&2
  packageList=`yum search $compName|grep "^$compName"`
  while read tempLine
  do
    #echo $Line
    packageName=`echo $tempLine | awk '{print $1}'`
    yum info $packageName|head -n 10
  done << EOF
  $packageList
EOF
fi
