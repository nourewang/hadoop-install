service hadoop-hdfs-namenode $1
service hadoop-hdfs-secondarynamenode $1
service hadoop-yarn-resourcemanager $1
service hadoop-mapreduce-historyserver $1

for node in cdh2 cdh3 cdh4 ;do
        ssh -i  /etc/edh/edh-id_rsa root@$node  "
		for x in zookeeper-server hadoop-hdfs-datanode hadoop-yarn-nodemanager hbase-master hbase-regionserver hive-metastore hive-server2; do  service \$x $1 ; done
	"
done

