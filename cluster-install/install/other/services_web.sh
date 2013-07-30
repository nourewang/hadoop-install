source $SCRIPTPATH/setenv.sh
# start or stop services.

INTELCLOUD_HOME=/usr/lib/intelcloud
USAGE_STR="./services_web.sh hostname hostip [start|stop] [hdfs|mapred|hbase|hive|oozie|all] [usekerberos]"
if [ $# -lt 5 ]
then
        echo $USAGE_STR
        exit
fi

Puppet_Config_Dir=/etc/puppet/config
Role_Config_File=/etc/puppet/config/role.csv
PUPPET_CLIENT=puppet
HADOOP_NAMENODE=hadoop-namenode
HADOOP_SECONDARYNAMENODE=hadoop-secondarynamenode
HADOOP_DATANODE=hadoop-datanode
HADOOP_JOBTRACKER=hadoop-jobtracker
HADOOP_TASKTRACKER=hadoop-tasktracker
HBASE_ZOOKEEPER=zookeeper-server
HBASE_MASTER=hbase-master
HBASE_REGIONSERVER=hbase-regionserver
MYSQL_SERVER=mysqld
HIVE_METASTORE=hive-metastore
HIVE_SERVER=hive-server
OOZIE=oozie

hostname=$1
hostip=$2
CurrentPath=$(cd "$(dirname "$0")"; pwd)


if [ "$3" = "start" ]
then
        oper_list="start"
        isRun="true"
elif [ "$3" = "stop" ]
then
        oper_list="stop"
        isRun="false"
else
        echo $USAGE_STR
        exit 1
fi

if [ "$4" = "hdfs" ]
then
        doOperHDFS="true"
elif [ "$4" = "hive" ]
then
        doOperHive="true"
elif [ "$4" = "oozie" ]
then
        doOperOozie="true"
elif [ "$4" = "mapred" ]
then
        doOperMapred="true"
elif [ "$4" = "hbase" ]
then
        doOperHBase="true"
elif [ "$4" = "all" ]
then
        doOperHDFS="true"
        doOperMapred="true"
        doOperHBase="true"
        doOperHive="true"
        doOperOozie="true"
        doOperPuppet="true"
else
        echo $USAGE_STR
        exit 1
fi

if [ "$5" = "true" ]
then
        useKerberos="true"
        keytabFile=$6
        principal=$7
else
        useKerberos="false"
fi

ssh $hostname source /root/.bashrc

tempRoles=`sed -n '/^'"$hostname",'/p' $Role_Config_File`
myRoles=`echo "$tempRoles" | awk 'BEGIN{FS=","}{for (i=2; i<=NF; i++) print $i}'`
for tempRole in  $myRoles
do
  if [ "$tempRole" == "hadoop_namenode" ]
  then 
     IS_NAMENODE_SERVER=true
  fi
  
  if [ "$tempRole" == "hadoop_datanode" ]
  then
     IS_DATANODE_SERVER=true
  fi

  if [ "$tempRole" == "hadoop_secondary_namenode" ]
  then
     IS_SECONDARYNAMENODE_SERVER=true
  fi


  if [ "$tempRole" == "hadoop_jobtracker" ]
  then
     IS_JOBTRACKER_SERVER=true
  fi


  if [ "$tempRole" == "hadoop_tasktracker" ]
  then
     IS_TASKTRACKER_SERVER=true
  fi

  if [ "$tempRole" == "hbase_master" ]
  then
     IS_HMASTER_SERVER=true
  fi

  if [ "$tempRole" == "hbase_regionserver" ]
  then
     IS_HREGIONSERVER_SERVER=true
  fi

  if [ "$tempRole" == "zookeeper_server" ]
  then 
     IS_ZK_SERVER=true
  fi
  
  if [ "$tempRole" == "hive_thrift_server" ]
  then 
     IS_HIVE_SERVER=true
  fi

  if [ "$tempRole" == "oozie_server" ]
  then 
     IS_OOZIE_SERVER=true
  fi
done

#stop puppet client first
if [ "$oper_list" == "stop" -a "$doOperPuppet" == "true" ]
then
  ssh root@$hostname service $PUPPET_CLIENT $oper_list
  ssh root@$hostname service gmond stop
  ssh root@$hostname yum remove ganglia-gmond -y
  ssh root@$hostname service im-agent stop
fi

function run_service(){
  hostname=$1
  servicename=$2
  toRun=$3
  tempCsvFile=$Puppet_Config_Dir/cluster-$hostname.csv
  if [ ! -f $tempCsvFile ]; then
    echo "" > $tempCsvFile
  fi
  sed -i '/^'"$servicename".run,'/d' $tempCsvFile
  echo "$servicename".run,"$toRun" >> $tempCsvFile
}

if [ "$doOperHDFS" = "true" ]
then
  if [ "${IS_NAMENODE_SERVER}" == "true" ]
  then
    run_service $hostname $HADOOP_NAMENODE $isRun
    ssh root@$hostname service $HADOOP_NAMENODE $oper_list
  fi
  
  if [ "${IS_SECONDARYNAMENODE_SERVER}" == "true" ]
  then
    run_service $hostname $HADOOP_SECONDARYNAMENODE $isRun
    ssh root@$hostname service $HADOOP_SECONDARYNAMENODE $oper_list
  fi
  
  if [ "${IS_DATANODE_SERVER}" == "true" ]
  then 
#    service hadoop-0.20-datanode $oper_list  
    run_service $hostname $HADOOP_DATANODE $isRun
    if [ "$oper_list" == "stop" ]; then  
        if [ "useKerberos" == "true" ]
        then
          kinit -kt $keytabFile $principal
          ssh root@$hostname "su -s /bin/bash hdfs -c \"hadoop dfsadmin -decommissionNodes $hostip\""
          nohup bash ${CurrentPath}/decommission_maintain.sh $hostname $hostip & 
        else
          ssh root@$hostname "su -s /bin/bash hdfs -c \"hadoop dfsadmin -decommissionNodes $hostip\""
          nohup bash ${CurrentPath}/decommission_maintain.sh $hostname $hostip & 
        fi
    else  
        ssh root@$hostname service $HADOOP_DATANODE $oper_list
    fi 
    
  fi
fi  

if [ "$doOperMapred" = "true" ]
then
  if [ "${IS_JOBTRACKER_SERVER}" == "true" ]
  then
    run_service $hostname $HADOOP_JOBTRACKER $isRun
    ssh root@$hostname service $HADOOP_JOBTRACKER $oper_list
  fi
  
  if [ "${IS_TASKTRACKER_SERVER}" == "true" ]
  then
    run_service $hostname $HADOOP_TASKTRACKER $isRun
    ssh root@$hostname service $HADOOP_TASKTRACKER $oper_list
  fi
fi

if [ "$doOperHBase" = "true" ]
then 
  if [ "${IS_HMASTER_SERVER}" == "true" ]
  then
    run_service $hostname $HBASE_MASTER $isRun
    ssh root@$hostname service $HBASE_MASTER $oper_list
  fi
  
  if [ "${IS_HREGIONSERVER_SERVER}" == "true" ]
  then
    run_service $hostname $HBASE_REGIONSERVER $isRun
    ssh root@$hostname service $HBASE_REGIONSERVER $oper_list
  fi 
  if [ "${IS_ZK_SERVER}" == "true" ]
  then  
    run_service $hostname $HBASE_ZOOKEEPER $isRun
    ssh root@$hostname service $HBASE_ZOOKEEPER $oper_list
  fi 
fi

if [ "$doOperHive" = "true" ]
then
  if [ "${IS_NAMENODE_SERVER}" == "true" ]; then
    run_service $hostname $MYSQL_SERVER $isRun
    run_service $hostname $HIVE_METASTORE $isRun
    if [ "$oper_list" == "start" ]
    then
      ssh root@$hostname service $MYSQL_SERVER $oper_list
      ssh root@$hostname service $HIVE_METASTORE $oper_list
    else
      ssh root@$hostname service $HIVE_METASTORE $oper_list
      ssh root@$hostname service $MYSQL_SERVER $oper_list
    fi
  fi

  if [ "${IS_HIVE_SERVER}" == "true" ]; then 
    run_service $hostname $HIVE_SERVER $isRun
    ssh root@$hostname service $HIVE_SERVER $oper_list  
  fi 
fi  

if [ "$doOperOozie" = "true" ]
then
  if [ "${IS_OOZIE_SERVER}" == "true" ]; then 
    run_service $hostname $OOZIE_SERVER $isRun
    ssh root@$hostname service $OOZIE_SERVER $oper_list  
  fi 
fi  

exit 0
