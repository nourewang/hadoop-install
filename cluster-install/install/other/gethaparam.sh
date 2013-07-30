source $SCRIPTPATH/setenv.sh
INTELCLOUD_CONF=/etc/intelcloud/
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 $1 cat $INTELCLOUD_CONF/haparams 2>/dev/null
