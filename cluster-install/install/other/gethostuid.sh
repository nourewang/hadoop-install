source $SCRIPTPATH/setenv.sh
#$1 host
#$2 host
#$3 user
host1=$1
host2=$2
user=$3
uid1=`ssh $host1 id -u $user 2>/dev/null`
uid2=`ssh $host2 id -u $user 2>/dev/null`
if [ "${uid1}" == "${uid2}" ]
then
 exit 0
else
 exit 1
fi
