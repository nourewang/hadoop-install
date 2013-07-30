source $SCRIPTPATH/setenv.sh
#$1 hostname
node=$1

ssh $node "
 cat /proc/mounts 2>/dev/null
"
