source $SCRIPTPATH/setenv.sh
# $1 compname
compName=$1

deployhome=/usr/lib/deploy/script/upgrade/

sh $deployhome/checkCompUpdate.sh $compName
