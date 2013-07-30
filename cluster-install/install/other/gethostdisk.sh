source $SCRIPTPATH/setenv.sh
host=$1
ssh $host cat /proc/partitions 2>/dev/null
