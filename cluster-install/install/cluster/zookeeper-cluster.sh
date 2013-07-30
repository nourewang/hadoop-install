#!/bin/sh

if [ $# -ne 1 ]; then
  echo "Usage: zookeeper-cluster.sh start|stop"
  exit 1
fi

export PDSH_SSH_ARGS_APPEND="-i /etc/intelcloud/idh-id_rsa"

TOPDIR=/usr/lib/intelcloud/scripts/zookeeper
CONFDIR=/etc/intelcloud/conf

action=$1

function start_nodes {
  nodelist=$1
  cmd=$2
  if [ -f $nodelist ]; then
    pdsh -S -w ^$nodelist $cmd
  fi
}

#start quorum
start_nodes $CONFDIR/zookeepers "$TOPDIR/zookeeper-service.sh zookeeper $action"
echo "Done for zookeeper(s) $action."
