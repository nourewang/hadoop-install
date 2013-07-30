#!/bin/sh

if [ $# -ne 1 ]; then
  echo "Usage: hdfs-cluster.sh start|stop|upgrade|upgrade-stop|rollback"
  exit 1
fi

export PDSH_SSH_ARGS_APPEND="-i /etc/intelcloud/idh-id_rsa"

TOPDIR=/usr/lib/intelcloud/scripts/hadoop
CONFDIR=/etc/intelcloud/conf

action=$1

function start_nodes {
  nodelist=$1
  cmd=$2
  if [ -f $nodelist ]; then
    pdsh -S -w ^$nodelist $cmd
  fi
}

#start namenode
start_nodes $CONFDIR/namenode "$TOPDIR/hadoop-service.sh namenode $action"
echo "Done for Namenode $action."

#start datanodes
start_nodes $CONFDIR/datanodes "$TOPDIR/hadoop-service.sh datanode $action"
echo "Done for datanode(s) $action."

#start secondary namenodes
start_nodes $CONFDIR/secondary_namenodes "$TOPDIR/hadoop-service.sh secondary_namenode $action"
echo "Done for Secondary Namnode(s) $action."

