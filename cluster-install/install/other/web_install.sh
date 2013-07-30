source $SCRIPTPATH/setenv.sh
# $1 is the dest machine
# $2 is the rsync server

scp /usr/lib/intelcloud/options $1:/usr/lib/intelcloud
rsync=`ps -ef|grep rsync|grep daemon`
if [ "x$rsync" == "x" ]
then
    /usr/bin/rsync --daemon
fi
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 $1 "bash /usr/lib/intelcloud/web_install.sh $2"
