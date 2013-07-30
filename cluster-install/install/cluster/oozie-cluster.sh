#!/bin/sh

if [ $# -ne 1 ]; then
  echo "Usage: hdfs-cluster.sh start|stop"
  exit 1
fi

export PDSH_SSH_ARGS_APPEND="-i /etc/intelcloud/idh-id_rsa"

TOPDIR=/usr/lib/intelcloud/scripts/oozie
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
start_nodes $CONFDIR/oozie "service oozie $action"
echo "Done for oozie $action."

