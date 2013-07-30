source $SCRIPTPATH/setenv.sh
#usage ./copyconfigurefile hostname filetype
#filetype contains hdfs: copy hdfs and hbase configure files
#filetype contails mapred: copy mapreduce configure files
#filetype contails zookeeper: copy zookeeper configure files
#filetype contails hbase: copy hbase configure files
#filetype contails hive: copy hive configure files
#filetype contails oozie: copy oozie configure files
WEBSERVERCONFIGHOME=/usr/lib/intelcloudui/webapps/webui/war/WEB-INF/data/conf

if [ $# -eq 3 ]
then
	WEBSERVERCONFIGHOME=$3
	if [ ! -d $WEBSERVERCONFIGHOME ]
        then
		mkdir -p $WEBSERVERCONFIGHOME
        fi
	HADOOPCONFHOME=$WEBSERVERCONFIGHOME/etc/hadoop
	MAPREDUCECONFHOME=$WEBSERVERCONFIGHOME/etc/hadoop
	ZOOKEEPERCONFHOME=$WEBSERVERCONFIGHOME/etc/zookeeper
	HBASECONFHOME=$WEBSERVERCONFIGHOME/etc/hbase
	HIVECONFHOME=$WEBSERVERCONFIGHOME/etc/hive
	OOZIECONFHOME=$WEBSERVERCONFIGHOME/etc/oozie
	if [ ! -d $HADOOPCONFHOME  ]
	then 
		mkdir -p $HADOOPCONFHOME 2>/dev/null 
	fi	    
	if [ ! -d $MAPREDUCECONFHOME ]
	then 
		mkdir -p $MAPREDUCECONFHOME 2>/dev/null 
	fi	    
	if [ ! -d $ZOOKEEPERCONFHOME ]
	then 
		mkdir -p $ZOOKEEPERCONFHOME 2>/dev/null 
	fi	    
	if [ ! -d $HBASECONFHOME ]
	then 
		mkdir -p $HBASECONFHOME 2>/dev/null 
	fi	    
	if [ ! -d $HIVECONFHOME ]
	then 
		mkdir -p $HIVECONFHOME 2>/dev/null 
	fi
	if [ ! -d $OOZIECONFHOME ]
	then 
		mkdir -p $OOZIECONFHOME 2>/dev/null 
	fi
	if [ "$2" == "hdfs" ]
	then
		scp -r root@$1:/etc/hadoop-0.20/conf  $HADOOPCONFHOME 2>/dev/null
	elif [ "$2" == "mapred"  ] 
	then
		scp -r root@$1:/etc/hadoop-0.20/conf $MAPREDUCECONFHOME 2>/dev/null
	elif [ "$2" == "zookeeper" ]
	then
		scp -r root@$1:/etc/zookeeper/* $ZOOKEEPERCONFHOME 2>/dev/null
	elif [ "$2" == "hbase" ] 
	then
		scp -r root@$1:/etc/hbase/conf  $HBASECONFHOME 2>/dev/null
	elif [ "$2" ==  "hive" ]
	then
		scp -r root@$1:/etc/hive/conf $HIVECONFHOME 2>/dev/null
	elif [ "$2" ==  "oozie" ]
	then
		scp -r root@$1:/etc/oozie/conf $OOZIECONFHOME 2>/dev/null
	fi
fi
