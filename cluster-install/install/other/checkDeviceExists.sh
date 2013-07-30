source $SCRIPTPATH/setenv.sh
host=$1
device=$2
ssh $host ls $device 2>/dev/null
