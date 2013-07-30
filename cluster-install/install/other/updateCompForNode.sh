source $SCRIPTPATH/setenv.sh
# $1 hsotname
# $2 compname
deployhome=/usr/lib/deploy/script/upgrade/
hostName=$1
compName=$2
sh $deployhome/updateCompForNode.sh $hostName $compName
