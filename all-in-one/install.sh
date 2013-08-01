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
echo "baseurl=http://localhost/edh/" >>/etc/yum.repos.d/cloudera-cdh4.repo
echo "gpgcheck = 0" >>/etc/yum.repos.d/cloudera-cdh4.repo

yum clean all

yum install -y hadoop  hadoop-debuginfo hadoop-hdfs-namenode hadoop-hdfs-datanode hadoop-hdfs-secondarynamenode hadoop-mapreduce-historyserver hadoop-yarn hadoop-yarn-resourcemanager  hadoop-yarn-nodemanager hive hive-metastore hive-server2 hive-jdbc zookeeper-server zookeeper

#wget ftp://192.168.0.30/pub/idh/hadoop_related/common/jdk-1.6.0_31-fcs.x86_64.rpm
#yum install jdk-1.6.0_31-fcs.x86_64.rpm

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


echo "format namenode"
rm -rf /hadoop/dfs
mkdir -p /hadoop/dfs/{name,data,namesecondary}
chown -R hdfs:hdfs /hadoop/dfs
chmod -R 700 /hadoop/dfs/


sh start.sh stop
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


