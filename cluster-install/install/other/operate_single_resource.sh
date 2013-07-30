source $SCRIPTPATH/setenv.sh
USAGE="sh operate_single_resource.sh start|stop|restart|cleanup resource node1[node2][node3]"
haToolsDIR=$SCRIPTPATH/../../../../../tools/ha/
. /etc/intelcloud/installation.conf
if [ "$OS_DISTRIBUTOR" == "sles" ]; then
  sh $haToolsDIR/SLES/operate_single_resource.sh $*
else
  sh $haToolsDIR/CentOS/operate_single_resource.sh $*
fi
