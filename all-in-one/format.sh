echo "format namenode"

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
   su -s /bin/bash hdfs -c "hadoop fs -mkdir -p $dir && hadoop fs -chmod -R $perm $dir && hadoop fs -chown -R $user:$group $dir"
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


