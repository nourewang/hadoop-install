
HOSTNAME=`hostname`

mkdir -p /etc/{hadoop,hive}/conf.edh
rm -rf /etc/{hadoop,hive}/conf

alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.edh 50
alternatives --set hadoop-conf /etc/hadoop/conf.edh

alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.edh 50
alternatives --set hive-conf /etc/hive/conf.edh

touch /var/lib/hive/.hivehistory
chown -R hive:hive  /var/lib/hive/.hivehistory

cp -rf conf-template/hadoop/conf/* /etc/hadoop/conf
cp -rf conf-template/hive/conf/* /etc/hive/conf

sed -i "s|HOSTNAME|$HOSTNAME|g" /etc/hadoop/conf/core-site.xml
sed -i "s|HOSTNAME|$HOSTNAME|g" /etc/hadoop/conf/hdfs-site.xml
sed -i "s|HOSTNAME|$HOSTNAME|g" /etc/hadoop/conf/mapred-site.xml
sed -i "s|HOSTNAME|$HOSTNAME|g" /etc/hadoop/conf/yarn-site.xml
sed -i "s|HOSTNAME|$HOSTNAME|g" /etc/hive/conf/hive-site.xml

