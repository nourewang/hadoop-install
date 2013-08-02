#!/bin/sh

if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi


services="hadoop-namenode hadoop-datanode hadoop-resourcemanager hadoop-nodemanager hadoop-secondarynamenode hbase-master hbase-regionserver hbase-thrift hive-metastore hive-server2  zookeeper-server"
for srvc in $services
do
	if service $srvc status >/dev/null 2>&1; then
		echo "Service $srvc is running. Begin to stop it."
		service $srvc stop >/dev/null 2>&1
	fi
done

for comp in hadoop hbase hive zookeeper
do
	echo "Uninstalling $comp ..."
	yum -y -q remove $comp >/dev/null 2>&1
	rm -rf /etc/$comp /usr/lib/$comp /var/log/$comp /var/lib/$comp
done

rm -rf /hadoop/dfs/name /hadoop/dfs/data /hadoop/dfs/namesecondary
