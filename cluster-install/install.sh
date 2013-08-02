if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi

HOSTNAME=`hostname`
PASSWORD='redhat'
export PDSH_SSH_ARGS_APPEND="-i /etc/edh/edh-id_rsa"

cd install
mkdir -p /etc/edh
cp -r ../edh/* /etc/edh/

sh initvar.sh
if [ "$?" != "0" ]; then
	exit 1
fi

sh install_manager.sh

if [ "$?" != "0" ]; then
	exit 1
fi

if [ -f /etc/edh/role.csv ]; then
    	NODELIST="`cat /etc/edh/role.csv | sed 's/,.*//g'`"
else
	echo "ERROR: Can not found role configuration file /etc/edh/role.csv"
	exit 1
fi

for node in $NODELIST ;do
	expect ssh_nopassword.exp $node $PASSWORD >/dev/null 2>&1
done

sh install_client.sh

cd ..

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
	ssh -q root@$node  "
		rm -rf /hadoop/dfs/{name,data,namesecondary} /hadoop/yarn/local
		mkdir -p /hadoop/dfs/{name,data,namesecondary} /hadoop/yarn/local

		chown -R hdfs:hdfs /hadoop/dfs/name
		chmod 700 /hadoop/dfs/name

		chown -R hdfs:hdfs /hadoop/dfs/data
		chmod 700 /hadoop/dfs/data

		chown -R hdfs:hdfs /hadoop/dfs/namesecondary
		chmod 700 /hadoop/dfs/namesecondary

		chown -R yarn:yarn /hadoop/yarn/local
		chmod 700 /hadoop/yarn/local
	"
	scp -q conf-template/hadoop/conf/* root@$node:/etc/hadoop/conf
	scp -q conf-template/hbase/conf/* root@$node:/etc/hbase/conf
	scp -q conf-template/hive/conf/* root@$node:/etc/hive/conf
	scp -q conf-template/zookeeper/conf/* root@$node:/etc/zookeeper/conf
done


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

