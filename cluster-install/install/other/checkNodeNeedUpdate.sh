source $SCRIPTPATH/setenv.sh
# $1 hostname
# $2 compName
hostName=$1
compName=$2

deployhome=/usr/lib/deploy/script/upgrade/

sh $deployhome/checkNodeNeedUpdate.sh $hostName $compName
