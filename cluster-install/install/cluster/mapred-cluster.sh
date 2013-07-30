#!/bin/sh

if [ $# -ne 1 ]; then
  echo "Usage: mapred-cluster.sh start|stop"
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
start_nodes $CONFDIR/jobtracker "$TOPDIR/hadoop-service.sh jobtracker $action"
echo "Done for Jobtracker $action."

#start datanodes
start_nodes $CONFDIR/tasktrackers "$TOPDIR/hadoop-service.sh tasktracker $action"
echo "Done for Tasktracker(s) $action."

