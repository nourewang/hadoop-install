#!/bin/sh

. /etc/edh/installation.conf

server=`hostname`
CLUSTER_CONF_DIR=/etc/edh

if [ -f $CLUSTER_CONF_DIR/role.csv ]; then
    	NODELIST="`cat $CLUSTER_CONF_DIR/role.csv | sed 's/,.*//g'`"
else
	echo "ERROR: Can not found role configuration file $CLUSTER_CONF_DIR/role.csv"
	exit 1
fi

for node in $NODELIST ;do
	if [ "x$server" != "x$node" ]; then
		sh config_yum_client.sh $node  $server 2>&1
		sh config_client.sh $node $server 2>&1
		ssh root@$node 'yum install -y hadoop-hdfs hadoop-libhdfs hadoop-debuginfo hadoop-httpfs hadoop-hdfs-namenode hadoop-yarn hadoop-yarn-nodemanager zookeeper-server hbase-master hbase-regionserver hbase-rest hbase-thrift hive hive-server2 hive-hbase hive-jdbc

		mkdir -p /etc/{hadoop,hbase,hive}/conf.edh
		rm -rf /etc/{hadoop,hbase,hive}/conf

		alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.edh 50
		alternatives --set hadoop-conf /etc/hadoop/conf.edh

		alternatives --install /etc/hbase/conf hbase-conf /etc/hbase/conf.edh 50
		alternatives --set hbase-conf /etc/hbase/conf.edh

		alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.edh 50
		alternatives --set hive-conf /etc/hive/conf.edh

		touch /var/lib/hive/.hivehistory
		chown -R hive:hive  /var/lib/hive/.hivehistory

	'
	else
		ssh root@$node 'yum install -y hadoop-hdfs hadoop-libhdfs hadoop-debuginfo hadoop-httpfs hadoop-hdfs-datanode hadoop-yarn hadoop-yarn-resoourcemanager hive-metastore
		
		mkdir -p /etc/hadoop/conf.edh
		rm -rf /etc/hadoop/conf

		alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.edh 50
		alternatives --set hadoop-conf /etc/hadoop/conf.edh
		'
	fi
done



