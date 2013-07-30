#!/bin/sh

if [ $# == 0 ]; then
  echo "USAGE: 
  ./uninstall.sh ALL|all
  ./uninstall.sh node1 node2 node3 ... 
  "; exit 1; 
fi

. /etc/edh/installation.conf

function clear_node {
  node=$1

  # check service
  ssh $node '
    function continue_ask {
      continue_flag="undef"
      while [ "$continue_flag" != "yes" -a "$continue_flag" != "no" ]
      do
        echo -n "Type yes to continue or no to exit uninstallation...[yes|no]: "
        read continue_flag
        if [ "$continue_flag" == "no" ]; then
          return 1
        fi
      done
      return 0
    }

    RETVAL=0

    if [ "`hostname`" == "'$SERVER_HOSTNAME'" ] && [ "'$SELF_INCLUDED'" == "false" ]; then
      RETVAL=5
      exit $RETVAL
    fi

    echo -e "\n************************************************************************************************************"
    echo "Clean hadoop hbase hive zookeeper sqoop mahout flume pig ganglia puppet nginx intel-manager for `hostname`?"
    echo "************************************************************************************************************"
    continue_ask
    RETVAL=$?
    [ $RETVAL -ne 0 ] && exit $RETVAL

    services="hadoop-namenode hadoop-datanode hadoop-resourcemanager hadoop-nodemanager hadoop-secondarynamenode hbase-master hbase-regionserver hbase-thrift hive-metastore hive-server mysql zookeeper-server oozie"
    for srvc in $services
    do
      if service $srvc status >/dev/null 2>&1; then
        echo "Service $srvc is running. Begin to stop it."
        service $srvc stop >/dev/null 2>&1
	#RETVAL=1
      fi
    done
    [ $RETVAL -ne 0 ] && exit $RETVAL

    services="puppet puppetmaster nginx pacemaker corosync  sqoop-metastore flume-node flume-master gmond gmetad nagios"
    for srvc in $services
    do
      service $srvc stop >/dev/null 2>&1
    done

    # check repo
    [ "'$REPO_BIN'" == "yum" ] && yum-complete-transaction >/dev/null 2>&1
    '$REPO_BIN' clean '$REPO_CLEANALL_OPT' >/dev/null 2>&1
    '$REPO_BIN' '$REPO_YES_OPT' -q remove puppet >/dev/null 2>&1
    if [ "$?" != "0"  ]; then 
      echo -e "\nERROR: Cannot connect to the EDH or OS '$REPO_BIN' repository. "
      echo "Please check the repo files in '$REPO_CONFDIR' on '$node'"
      echo "And make sure the IDH and OS '$REPO_BIN' repository availabe. "
      exit 3
    fi

    if [ "'$REPO_BIN'" == "zypper" ]; then
      rpm -e `rpm -qa | grep zookeeper-server` --noscripts > /dev/null 2>&1
    fi

    for comp in pacemaker corosync hadoop hbase hive mysql zookeeper sqoop mahout flume pig oozie ganglia nagios puppet nginx ftpoverhdfs
    do
      echo "Uninstalling $comp ..."
      '$REPO_BIN' '$REPO_YES_OPT' -q remove $comp >/dev/null 2>&1
      rm -rf /etc/$comp /usr/lib/$comp /var/log/$comp /var/lib/$comp
    done

    echo "Uninstalling other related packages"
    '$REPO_BIN' '$REPO_YES_OPT' -q remove hadoop-doc hbase-doc oozie-client libganglia ganglia-gmetad ganglia-gmond ganglia-web ganglia-gmond-modules-python nagios-plugins >/dev/null 2>&1
    '$REPO_BIN' '$REPO_YES_OPT' -q remove hadoop-debuginfo > /dev/null 2>&1

    echo "Uninstalling Embrace Manager for Apache Hadoop"
    if [ "'$REPO_BIN'" == "yum" ]; then
      '$REPO_BIN' '$REPO_YES_OPT' -q remove idh-management intelcloudui >/dev/null 2>&1
    else
      rpm -e `rpm -qa | grep -E "idh|intelcloudui"` >/dev/null 2>&1
    fi

    echo "Removing related directories ..."
    rm -rf /etc/edh
    rm -rf /etc/default
    rm -rf /usr/lib64/ganglia
    rm -rf '$FTP_DIR'/os
    rm -rf '$FTP_DIR'/os_related
    rm -rf '$FTP_DIR'/edh
    rm -rf /var/zookeeper
    rm -rf /var/spool/nagios/nagios.cmd
    rm -rf /var/cache/'$REPO_BIN'
    rm -rf '$HTTP_DIR'/logs

    # recovery repo files
    cd '$REPO_CONFDIR'
    rm -rf os.repo* idh.repo*
    rename .repo.bak .repo *
    cd - >/dev/null

    echo "Uninstallation for '$node' finished."
  '

  retval=$?
  if [ "$retval" != "0" ]; then
    return $retval
  fi
}

SERVER_HOSTNAME=`hostname`
SELF_INCLUDED=false
CLUSTER_CONF_DIR=/etc/edh

if [ "$1" == "ALL" ] || [ "$1" == "all" ]; then
  if [ -f $CLUSTER_CONF_DIR/role.csv ]; then
    NODELIST="`cat $CLUSTER_CONF_DIR/role.csv | sed 's/,.*//g'`"
  else
    echo "ERROR: Can not found role configuration file $CLUSTER_CONF_DIR/role.csv"
  fi
else
  NODELIST=$*
fi

if ! service vsftpd status >/dev/null 2>&1; then
  service vsftpd start
fi


for eachnode in $NODELIST
do
  clear_node $eachnode
  retval=$?
  if [ $retval != 0 ]; then
    [ "$retval" == "5" ] && SELF_INCLUDED="true"
    continue
  fi
done

if [ "$SELF_INCLUDED" == "true" ]; then
  echo "WARN: Please make sure all the other nodes of the cluster have been uninstalled before the management node."
  clear_node localhost
fi
