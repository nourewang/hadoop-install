
HOSTNAME=`hostname`

rm -rf /etc/{hadoop,hive,hbase,zookeeper}/{conf,conf.edh}
mkdir -p /etc/{hadoop,hive,hbase,zookeeper}/conf.edh

alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.edh 50
alternatives --set hadoop-conf /etc/hadoop/conf.edh

alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.edh 50
alternatives --set hive-conf /etc/hive/conf.edh

alternatives --install /etc/hbase/conf hbase-conf /etc/hbase/conf.edh 50
alternatives --set hbase-conf /etc/hbase/conf.edh

alternatives --install /etc/zookeeper/conf zookeeper-conf /etc/zookeeper/conf.edh 50
alternatives --set zookeeper-conf /etc/zookeeper/conf.edh

touch /var/lib/hive/.hivehistory
chown -R hive:hive  /var/lib/hive/.hivehistory

cp -u conf-template/hadoop/conf/* /etc/hadoop/conf
cp -u conf-template/hive/conf/* /etc/hive/conf
cp -u conf-template/hbase/conf/* /etc/hbase/conf
cp -u conf-template/zookeeper/conf/* /etc/zookeeper/conf

