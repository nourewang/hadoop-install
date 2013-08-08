if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi


HOSTNAME=`hostname`
iptables -F

#yum-config-manager --add-repo=http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/cloudera-cdh4.repo
#sudo rpm --import http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera

echo "[cloudera-cdh4]" >/etc/yum.repos.d/cloudera-cdh4.repo
echo "name=cdh4" >>/etc/yum.repos.d/cloudera-cdh4.repo
#echo "baseurl=ftp://192.168.0.254/pub/cdh/4" >>/etc/yum.repos.d/cloudera-cdh4.repo
echo "baseurl=ftp://192.168.56.101/pub/cdh/4.3.0/" >>/etc/yum.repos.d/cloudera-cdh4.repo
echo "gpgcheck = 0" >>/etc/yum.repos.d/cloudera-cdh4.repo
yum clean all -q 2>/dev/null

yum install -y -q hadoop  hadoop-debuginfo hadoop-hdfs-namenode hadoop-hdfs-datanode hadoop-hdfs-secondarynamenode hadoop-mapreduce-historyserver hadoop-yarn hadoop-yarn-resourcemanager  hadoop-yarn-nodemanager hive hive-metastore hive-server2 hive-jdbc zookeeper-server zookeeper hbase hbase-master hbase-regionserver 2>/dev/null

#wget ftp://192.168.0.30/pub/idh/hadoop_related/common/jdk-1.6.0_31-fcs.x86_64.rpm
#yum install jdk-1.6.0_31-fcs.x86_64.rpm


#curl -s http://archive.cloudera.com/cdh4/ubuntu/lucid/amd64/cdh/archive.key | sudo apt-key add -
#sudo apt-get update 

if [ -f /root/.bashrc ] ; then
    sed -i '/^export[[:space:]]\{1,\}JAVA_HOME[[:space:]]\{0,\}=/d' /root/.bashrc
    sed -i '/^export[[:space:]]\{1,\}CLASSPATH[[:space:]]\{0,\}=/d' /root/.bashrc
    sed -i '/^export[[:space:]]\{1,\}PATH[[:space:]]\{0,\}=/d' /root/.bashrc
fi
echo "" >>/root/.bashrc
echo "export JAVA_HOME=/usr/java/latest" >>/root/.bashrc
echo "export CLASSPATH=.:\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar">>/root/.bashrc
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /root/.bashrc

source /root/.bashrc

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

echo "format namenode"
sh start.sh stop

rm -rf /hadoop/dfs /var/lib/zookeeper
mkdir -p /hadoop/dfs/{name,data,namesecondary} /var/lib/zookeeper
chown -R hdfs:hdfs /hadoop/dfs && chmod -R 700 /hadoop/dfs/
chown -R zookeeper:zookeeper /var/lib/zookeeper && chmod -R 700 /var/lib/zookeeper

service zookeeper-server init --myid=1

su -s /bin/bash hdfs -c 'yes Y | hadoop namenode -format >> /tmp/nn.format.log 2>&1'

service hadoop-hdfs-namenode start
sleep 5

su -s /bin/bash hdfs -c "hadoop fs -chmod a+rw /"
while read dir user group perm
do
   su -s /bin/bash hdfs -c "hadoop fs -mkdir $dir && hadoop fs -chmod $perm $dir && hadoop fs -chown $user:$group $dir"
     echo "[IM_CONFIG_INFO]: ."
done << EOF
/tmp hdfs hadoop 1777 
/tmp/hadoop-yarn mapred mapred 777
/var hdfs hadoop 755 
/var/log yarn mapred 1775 
/var/log/hadoop-yarn/apps yarn mapred 1777
/hbase hbase hadoop 755
/user hdfs hadoop 777
/user/history mapred hadoop 1777
/user/root root hadoop 777
/user/hive hive hadoop 777 
EOF

echo "start hadoop"
sh start.sh start


