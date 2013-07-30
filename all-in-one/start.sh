if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi

for x in  hadoop-hdfs-namenode zookeeper-server hadoop-hdfs-datanode hadoop-yarn-resourcemanager hadoop-yarn-nodemanager hadoop-mapreduce-historyserver hive-metastore hive-server2 ; do  
	service $x $1 ; 
done



