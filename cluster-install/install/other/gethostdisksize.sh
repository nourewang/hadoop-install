source $SCRIPTPATH/setenv.sh
host=$1
partition=$2
ssh $host blockdev --getsize64 $partition
