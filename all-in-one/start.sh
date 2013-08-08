if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi

for x in  hadoop-hdfs-namenode hadoop-hdfs-datanode hadoop-yarn-resourcemanager hadoop-yarn-nodemanager hadoop-mapreduce-historyserver hive-metastore hive-server2 hbase-master hbase-regionserver zookeeper-server; do  
	service $x $1 ; 
done



