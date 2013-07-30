source $SCRIPTPATH/setenv.sh
USAGE="sh operate_single_node.sh start|online|standby|configure|cleanup hostname"

haToolsDIR=$SCRIPTPATH/../../../../../tools/ha/
. /etc/intelcloud/installation.conf
if [ "$OS_DISTRIBUTOR" == "sles" ]; then
  sh $haToolsDIR/SLES/operate_single_node.sh $*
else
  sh $haToolsDIR/CentOS/operate_single_node.sh $*
fi
