source $SCRIPTPATH/setenv.sh
#1 component name
comp=$1
deployhome=/usr/lib/deploy/script/upgrade/
sh $deployhome/getCompInfo.sh $comp
