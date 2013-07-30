source $SCRIPTPATH/setenv.sh
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 $1 cat /usr/lib/intelcloud/myrole
