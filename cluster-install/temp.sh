if [ -f /etc/edh/role.csv ]; then
    	NODELIST="`cat /etc/edh/role.csv | sed 's/,.*//g'`"
else
	echo "ERROR: Can not found role configuration file /etc/edh/role.csv"
	exit 1
fi

HOSTNAME=`hostname`

cp -f  conf-template/hadoop/conf/core-site.xml.template  conf-template/hadoop/conf/core-site.xml
cp -f  conf-template/hadoop/conf/hdfs-site.xml.template  conf-template/hadoop/conf/hdfs-site.xml
cp -f  conf-template/hadoop/conf/mapred-site.xml.template  conf-template/hadoop/conf/mapred-site.xml
cp -f  conf-template/hadoop/conf/yarn-site.xml.template  conf-template/hadoop/conf/yarn-site.xml
cp -f  conf-template/hive/conf/hive-site.xml.template  conf-template/hive/conf/hive-site.xml
cp -f  conf-template/hbase/conf/hbase-site.xml.template  conf-template/hbase/conf/hbase-site.xml

sed -i "s|HOSTNAME|$HOSTNAME|g" conf-template/hadoop/conf/core-site.xml
sed -i "s|HOSTNAME|$HOSTNAME|g" conf-template/hadoop/conf/hdfs-site.xml
sed -i "s|HOSTNAME|$HOSTNAME|g" conf-template/hadoop/conf/mapred-site.xml
sed -i "s|HOSTNAME|$HOSTNAME|g" conf-template/hadoop/conf/yarn-site.xml
sed -i "s|HOSTNAME|$HOSTNAME|g" conf-template/hive/conf/hive-site.xml
sed -i "s|HOSTNAME|$HOSTNAME|g" conf-template/hbase/conf/hbase-site.xml

for node in $NODELIST ;do
	scp -q conf-template/hadoop/conf/* root@$node:/etc/hadoop/conf
	scp -q conf-template/hbase/conf/* root@$node:/etc/hbase/conf
	scp -q conf-template/hive/conf/* root@$node:/etc/hive/conf
	scp -q conf-template/zookeeper/conf/* root@$node:/etc/zookeeper/conf
done

