#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: hbase-cluster.sh start [use_kerberos]|stop [active_master] [use_kerberos keytab principal]"
  exit 1
fi

export PDSH_SSH_ARGS_APPEND="-i /etc/intelcloud/idh-id_rsa"

TOPDIR=/usr/lib/intelcloud/scripts/hbase
CONFDIR=/etc/intelcloud/conf
HBASE_HOME=/usr/lib/hbase

action=$1
if [ $action == "start" ]; then
  if [  $# -ge 2 ]; then
    use_kerberos=$2
  fi
else
  if [  $# -eq 2 ]; then
    active_master=$2
  fi
  if [ $# -gt 3 ]; then
    use_kerberos=$3
    keytab=$4
    principal=$5
  fi
fi

function start_nodes {
  nodelist=$1
  cmd=$2
  if [ -f $nodelist ]; then
    pdsh -S -w ^$nodelist $cmd
  fi
}

if [ "$action" == "start" ]; then
  #start master
  start_nodes $CONFDIR/hbase_masters "$TOPDIR/hbase-service.sh master $action"
  echo "Done for HBase Master(s) $action."

  #start region servers
  start_nodes $CONFDIR/hbase_regionservers "$TOPDIR/hbase-service.sh regionserver $action"
  echo "Done for HBase RegionServer(s) $action."

  #start thrift servers
  if [ "$use_kerberos" == "true" ]; then
    start_nodes $CONFDIR/hbase_thrifts "$TOPDIR/hbase-service.sh thrift-kerberos $action" 
  else
    start_nodes $CONFDIR/hbase_thrifts "$TOPDIR/hbase-service.sh thrift $action" 
  fi
  echo "Done for HBase thrift server(s) $action."
fi



if [ "$action" == "stop" ]; then

   #stop backup masters
  if [ -f $CONFDIR/hbase_masters ]; then
    tmpfile=`mktemp`
    if [ "x$active_master" != "x" ]; then
        cat $CONFDIR/hbase_masters | grep -v "$active_master" >$tmpfile
    else
        cat $CONFDIR/hbase_masters >$tmpfile
    fi
    start_nodes $tmpfile "$TOPDIR/hbase-service.sh master $action"
  fi

  echo "Done for Backup HBase Master(s) $action."

    #stop active master
  if [ "x$active_master" != "x" ]; then
    echo "$active_master: stopping active master..."
    if [ "$use_kerberos" == "true" ]; then
      remote_cmd="kinit -kt $keytab $principal; ksu hbase -n ${principal} -e ${HBASE_HOME}/bin/hbase --config /etc/hbase/conf master stop"
      pdsh -S -w $active_master "$remote_cmd | perl -pe 's/\r|\e\[?.*?[\@-~]//g';  exit \${PIPESTATUS[0]}"
    else
      remote_cmd="su -s /bin/sh hbase -c \"${HBASE_HOME}/bin/hbase --config /etc/hbase/conf master stop\""
      pdsh -S -w $active_master "$remote_cmd | perl -pe 's/\r|\e\[?.*?[\@-~]//g';  exit \${PIPESTATUS[0]}"
    fi
    echo
  fi 
  echo "Done for Active HBase Master $action." 

  start_nodes $CONFDIR/hbase_thrifts "$TOPDIR/hbase-service.sh thrift $action" 
  echo "Done for HBase thrift server(s) $action."
fi

if [ "$action" == "force-stop" ]; then

  #stop master
  start_nodes $CONFDIR/hbase_masters "$TOPDIR/hbase-service.sh master $action"
  echo "Done for HBase Master(s) $action."

  #stop region servers
  start_nodes $CONFDIR/hbase_regionservers "$TOPDIR/hbase-service.sh regionserver $action"
  echo "Done for HBase RegionServer(s) $action."

  #stop thrift servers
  if [ "$use_kerberos" == "true" ]; then
    start_nodes $CONFDIR/hbase_thrifts "$TOPDIR/hbase-service.sh thrift-kerberos $action"
  else
    start_nodes $CONFDIR/hbase_thrifts "$TOPDIR/hbase-service.sh thrift $action"
  fi
  echo "Done for HBase thrift server(s) $action."

fi
