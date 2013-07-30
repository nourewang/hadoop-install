source $SCRIPTPATH/setenv.sh
# $1 namenode
# $2 useKerberos
# $3 keytab
# $4 principal
namenode=$1
useKerberos=$2
if [ "$useKerberos" == "true" ]
then
  ssh $namenode "
     kinit -kt $3 $4
     hadoop fsck /
"
else
  ssh $namenode "hadoop fsck /"
fi

