#!/bin/bash

function usage() {
  echo "Usage: hadoop-acl.sh [-secured] <command>"
  echo "  where command can be:"
  echo "                do_acl"
  exit 1
}

secured="NO"
command=""
if [ $# -eq 1 ]; then
  command="$1"
elif [ $# -eq 2 ]; then
  if [ X"$1" = X"-secured" ]; then
    secured="YES"
  else
    usage
  fi   
  command="$2"
else
  usage  
fi

if [ $secured == "YES" ]; then
  host=`hostname -f`
  patn="hdfs/$host"
  principal=`su -s /bin/bash hdfs -c "klist -k /etc/hdfs.keytab" | grep $patn | head -n1 | awk '{print $2}'`
  if [ X"$principal" == X ]; then
    echo "Failed to get hdfs Kerberos principal"
    exit 1
  fi
  su -s /bin/bash hdfs -c "kinit -kt /etc/hdfs.keytab $principal"
  if [ $? -ne 0 ]; then
    echo "Failed to login as hdfs by kinit command"
    exit 1
  fi
fi

if [ $command == "do_acl" ]; then
  su -s /bin/bash hdfs -c "hadoop dfsadmin -refreshServiceAcl"
  su -s /bin/bash hdfs -c "hadoop mradmin -refreshServiceAcl"
  su -s /bin/bash hdfs -c "hadoop dfsadmin -refreshUserToGroupsMappings"
  su -s /bin/bash hdfs -c "hadoop mradmin -refreshUserToGroupsMappings"
fi
   
exit 0