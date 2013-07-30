#!/bin/bash

function usage() {
  echo "Usage: hive-acl.sh [-secured] <command>"
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
  patn="hive/$host"
  principal=`su -s /bin/bash hive -c "klist -k /etc/hive.keytab" | grep $patn | head -n1 | awk '{print $2}'`
  if [ X"$principal" == X ]; then
    echo "Failed to get hive Kerberos principal"
    exit 1
  fi
  su -s /bin/bash hive -c "kinit -kt /etc/hive.keytab $principal"
  if [ $? -ne 0 ]; then
    echo "Failed to login as hive by kinit command"
    exit 1
  fi
fi

runScript="/tmp/hive-acl.run.$$"
if [ $command == "list_all_tables" ]; then
  su -s /bin/bash hive -c "hive -S -e \"show databases;\"" 2>/dev/null | while read line; do
    db="$line"
    tables=`su -s /bin/bash hive -c "hive -S -e \"use $db;show tables;\"" 2>/dev/null`
    tables=`echo $tables`
    echo "$db:$tables"
  done
elif [ $command == "do_acl" ]; then
  rm -rf /tmp/hive-acl.runned
  cp /usr/lib/intelcloud/scripts/hive/hive-acl /tmp/hive-acl.runned
  
  su -s /bin/bash hive -c "hive -S -e \"show databases;\"" >> /tmp/hive-acl.log 2>&1
  if [ $? -eq 1 ]; then
    echo "Failed to enforce hive acl. Please double check hive service is running fine."
    exit 1
  fi
  
  #hive -S -f /usr/lib/intelcloud/scripts/hive/hive-acl
  date >> /tmp/hive-acl.log
  cat /usr/lib/intelcloud/scripts/hive/hive-acl | while read line; do 
    su -s /bin/bash hive -c "hive -S -e \"$line\"" >> /tmp/hive-acl.log 2>&1
  done
  
  exit 0
fi

exit $?
