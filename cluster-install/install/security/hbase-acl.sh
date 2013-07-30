#!/bin/bash

function usage() {
  echo "Usage: hbase-acl.sh [-secured] <command>"
  echo "  where command can be:"
  echo "                list_all_tables"
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
  patn="hbase/$host"
  principal=`su -s /bin/bash hbase -c "klist -k /etc/hbase.keytab" | grep $patn | head -n1 | awk '{print $2}'`
  if [ X"$principal" == X ]; then
    echo "Failed to get hbase Kerberos principal"
    exit 1
  fi
  su -s /bin/bash hbase -c "kinit -kt /etc/hbase.keytab $principal"
  if [ $? -ne 0 ]; then
    echo "Failed to login as hbase by kinit command"
    exit 1
  fi
fi

runScript="/tmp/hbase-acl.run.$$"
if [ $command == "list_all_tables" ]; then
  echo "load '/usr/lib/intelcloud/scripts/hbase/hbase-acl.rb'" >> $runScript
  echo "list_all_tables" >> $runScript
  echo "exit 0" >> $runScript
  su -s /bin/bash hbase -c "hbase shell $runScript" | grep -v '_acl_'
elif [ $command == "do_acl" ]; then
  rm -rf /tmp/hbase-acl.runned
  cp /usr/lib/intelcloud/scripts/hbase/hbase-acl /tmp/hbase-acl.runned
  date >> /tmp/hbase-acl.log
  su -s /bin/bash hbase -c "hbase shell /usr/lib/intelcloud/scripts/hbase/hbase-acl" >> /tmp/hbase-acl.log 2>&1
  if [ $? -eq 1 ]; then
    echo "Failed to enforce hbase acl. Please double check if hbase master is running fine."
    exit 1
  fi
fi
   
exit $?
