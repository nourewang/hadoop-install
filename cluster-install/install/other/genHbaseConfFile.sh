source $SCRIPTPATH/setenv.sh
#!/bin/sh
INTELCLOUD_HOME=/usr/lib/intelcloud
INTELCLOUD_CONF=/etc/intelcloud

PARAM_FILE=${INTELCLOUD_CONF}/gparams
OPTIONS_FILE=${INTELCLOUD_HOME}/options

if [[ ! -f ${PARAM_FILE} ]]
then
	echo "ERROR: The parameter file is missing."
	exit 1
fi 


. ${PARAM_FILE}


doConfigHDFS="true"
doConfigMAPRED="true"
doConfigHBase="true"
doConfigZK="true"
doConfigEnv="true"


# set constant variables
HADOOP_CONF_BASE=/etc/hadoop-0.20
HADOOP_CONF_NAME=hadoop-0.20-conf
HADOOP_DEFAULT_HEAPSIZE=1000
HADOOP_DEFAULT_NAMENODE_OPTS='-Dcom.sun.management.jmxremote $HADOOP_NAMENODE_OPTS'
HADOOP_DEFAULT_SECONDARYNAMENODE_OPTS='-Dcom.sun.management.jmxremote $HADOOP_SECONDARYNAMENODE_OPTS'
HADOOP_DEFAULT_DATANODE_OPTS='-Dcom.sun.management.jmxremote $HADOOP_DATANODE_OPTS'
HADOOP_DEFAULT_JOBTRACKER_OPTS='-Dcom.sun.management.jmxremote $HADOOP_JOBTRACKER_OPTS'
HADOOP_DEFAULT_TASKTRACKER_OPTS=
HADOOP_NAMENODE_DEBUG_PORT=8441
HADOOP_SECONDARYNAMENODE_DEBUG_PORT=8442
HADOOP_DATANODE_DEBUG_PORT=8443
HADOOP_JOBTRACKER_DEBUG_PORT=8444
HADOOP_TASKTRACKER_DEBUG_PORT=8445
MAPRED_MIN_JOBTRACKER_HANDLER_COUNT=10
MAPRED_MIN_CHILD_HEAPSIZE=200

HBASE_CONF_DIR=/etc/hbase/conf
HBASE_DEFAULT_HEAPSIZE=1000
HBASE_DEFAULT_MASTER_OPTS=
HBASE_DEFAULT_REGIONSERVER_OPTS=
HBASE_MASTER_DEBUG_PORT=12441
HBASE_REGIONSERVER_DEBUG_PORT=12442
ZK_CONF_DIR=/etc/zookeeper

# set script variables to default values

HADOOP_CONF_DIR=conf.${cluster_name}
DFS_NAME_DIR=/hadoop/hadoop_image_local
DFS_DRBD_NAME_DIR=/hadoop/hadoop_image
DFS_DATA_DIR_REL=hadoop/data
DFS_REPLICATION=3
DFS_BLOCKSIZE=67108864
DFS_NAMENODE_HANDLER_COUNT=100
DFS_DATANODE_MAX_XCIEVERS=65536
MAPRED_LOCAL_DIR_REL=hadoop/mapred
MAPRED_LOCAL_DIR=
MAPRED_SYSTEM_DIR=/mapred/system
MAPRED_TMP_DIR=/var/hadoop/tmp/mapred/tmp
MAPRED_JOBTRACKER_STAGING_ROOT_DIR=/var/hadoop/mapred/staging
MAPRED_HADOOP_TMP_DIR=/var/hadoop/tmp
MAPRED_IO_SORT_FACTOR=10
MAPRED_IO_SORT_MB=100
MAPRED_MIN_SPLIT_SIZE=0
MAPRED_REDUCE_COPY_BACKOFF=300
MAPRED_JOB_REUSE_JVM_NUM_TASKS=1
MAPRED_JOB_SHUFFLE_MERGE_PERCENT=0.66
MAPRED_JOB_SHUFFLE_INPUT_BUFFER_PERCENT=0.70
MAPRED_JOB_REDUCE_INPUT_BUFFER_PERCENT=0.0
MAPRED_TASK_TIMEOUT=180000
MAPRED_TASKTRACKER_EXPIRY_INTERVAL=180000
HADOOP_NAMENODE_HEAPSIZE=
HADOOP_SECONDARYNAMENODE_HEAPSIZE=
HADOOP_DATANODE_HEAPSIZE=
HADOOP_JOBTRACKER_HEAPSIZE=
HADOOP_TASKTRACKER_HEAPSIZE=
HADOOP_TASKTRACKER_RESERVE=
HADOOP_NAMENODE_HEAPSIZE_WEIGHT=0
HADOOP_SECONDARYNAMENODE_HEAPSIZE_WEIGHT=0
HADOOP_DATANODE_HEAPSIZE_WEIGHT=0
HADOOP_JOBTRACKER_HEAPSIZE_WEIGHT=0
HADOOP_TASKTRACKER_HEAPSIZE_WEIGHT=0
HADOOP_TASKTRACKER_RESERVE_WEIGHT=0
DEBUG_HADOOP=false

HBASE_MASTER_PORT=60000
HBASE_MASTER_INFO_PORT=60010
HBASE_REGIONSERVER_PORT=60020
HBASE_REGIONSERVER_INFO_PORT=60030
HBASE_MAX_FILESIZE=268435456
HBASE_HREGION_MEMSTORE_FLUSH_SIZE=134217728
HBASE_ZK_SESSION_TIMEOUT=180000
HBASE_REGIONSERVER_HANDLER_COUNT=50
HBASE_HFILE_BLOCK_CACHE_SIZE=0.2
HBASE_REGIONSERVER_THREAD_COMPACTION_LARGE=4
HBASE_REGIONSERVER_THREAD_COMPACTION_SMALL=4
HBASE_REGIONSERVER_THREAD_SPLIT=4
HBASE_MASTER_HEAPSIZE=
HBASE_REGIONSERVER_HEAPSIZE=
HBASE_MASTER_HEAPSIZE_WEIGHT=0
HBASE_REGIONSERVER_HEAPSIZE_WEIGHT=0
DEBUG_HBASE=false

ZK_TICKTIME=2000
ZK_DATADIR=/var/zookeeper

MAPRED_FS_DEFAULT_NAME_S=                       
MAPRED_HADOOP_TMP_DIR_S=                        
MAPRED_LOCAL_DIR_S=                             
MAPRED_SYSTEM_DIR_S=                            
MAPRED_JOBTRACKER_STAGING_ROOT_DIR_S=           
MAPRED_TMP_DIR_S=         

# set script variables according to user input

HDFS_NAMENODE=$hdfs_namenode
MAPRED_JOBTRACKER=$mapred_jobtracker
ZK_QUORUM_SERVERS=$zk_servers

if [ "$ZK_QUORUM_SERVERS" == "" ]
then
  doConfigHBase="false"
  doConfigZK="false"
fi

if [ ! -z $dfs_name_dir ]; then
  DFS_NAME_DIR=$dfs_name_dir
fi

if [ ! -z $dfs_data_dir ]; then
  DFS_DATA_DIR=$dfs_data_dir
fi
	
if [ "$kickstart_soft_install" == "true" ]
then
	MAPRED_LOCAL_DIR=$mapred_local_dir
fi

if [ ! -z $dfs_replication ]; then
	DFS_REPLICATION=$dfs_replication
fi
if [ ! -z $dfs_blocksize ]; then
	DFS_BLOCKSIZE=$dfs_blocksize
fi
if [ ! -z $dfs_namenode_handler_count ]; then
        DFS_NAMENODE_HANDLER_COUNT=$dfs_namenode_handler_count
fi
if [ ! -z $dfs_datanode_max_xcievers ]; then
	DFS_DATANODE_MAX_XCIEVERS=$dfs_datanode_max_xcievers
fi
ESTIMATED_TASKTRACKER_COUNT=$estimated_tasktracker_count
if [ ! -z $mapred_io_sort_factor ]; then
	MAPRED_IO_SORT_FACTOR=$mapred_io_sort_factor
fi
if [ ! -z $mapred_io_sort_mb ]; then
	MAPRED_IO_SORT_MB=$mapred_io_sort_mb
fi
if [ ! -z $mapred_min_split_size ]; then
	MAPRED_MIN_SPLIT_SIZE=$mapred_min_split_size
fi
if [ ! -z $mapred_reduce_copy_backoff ]; then
	MAPRED_REDUCE_COPY_BACKOFF=$mapred_reduce_copy_backoff
fi
if [ ! -z $mapred_job_reuse_jvm_num_tasks ]; then
	MAPRED_JOB_REUSE_JVM_NUM_TASKS=$mapred_job_reuse_jvm_num_tasks
fi
if [ ! -z $mapred_job_shuffle_merge_percent ]; then
	MAPRED_JOB_SHUFFLE_MERGE_PERCENT=$mapred_job_shuffle_merge_percent
fi
if [ ! -z $mapred_job_shuffle_input_buffer_percent ]; then
	MAPRED_JOB_SHUFFLE_INPUT_BUFFER_PERCENT=$mapred_job_shuffle_input_buffer_percent
fi
if [ ! -z $mapred_job_reduce_input_buffer_percent ]; then
	MAPRED_JOB_REDUCE_INPUT_BUFFER_PERCENT=$mapred_job_reduce_input_buffer_percent
fi

if [ ! -z $debug_hadoop ]; then
	DEBUG_HADOOP=$debug_hadoop
fi

if [ ! -z $mapred_fs_default_name ]; then
	MAPRED_FS_DEFAULT_NAME_S=$mapred_fs_default_name
	MAPRED_SYSTEM_DIR_S="$MAPRED_FS_DEFAULT_NAME_S/mapred/system"
	MAPRED_JOBTRACKER_STAGING_ROOT_DIR_S="$MAPRED_FS_DEFAULT_NAME_S/mapred/staging"
	MAPRED_TMP_DIR_S="$MAPRED_FS_DEFAULT_NAME_S/mapred/tmp"
fi

if [ ! -z $mapred_local_dir ]; then
	MAPRED_LOCAL_DIR_S=$mapred_local_dir
fi

if [ ! -z $hbase_master_port ]; then
        HBASE_MASTER_PORT=$hbase_master_port
fi
if [ ! -z $hbase_master_info_port ]; then
        HBASE_MASTER_INFO_PORT=$hbase_master_info_port
fi
if [ ! -z $hbase_regionserver_port ]; then
        HBASE_REGIONSERVER_PORT=$hbase_regionserver_port
fi
if [ ! -z $hbase_regionserver_info_port ]; then
        HBASE_REGIONSERVER_INFO_PORT=$hbase_regionserver_info_port
fi
if [ ! -z $hbase_max_filesize ]; then
	HBASE_MAX_FILESIZE=$hbase_max_filesize
fi
if [ ! -z $hbase_hregion_memstore_flush_size ]; then
	HBASE_HREGION_MEMSTORE_FLUSH_SIZE=$hbase_hregion_memstore_flush_size
fi
if [ ! -z $hbase_zk_session_timeout ]; then
	HBASE_ZK_SESSION_TIMEOUT=$hbase_zk_session_timeout
fi
if [ ! -z $hbase_regionserver_handler_count ]; then
	HBASE_REGIONSERVER_HANDLER_COUNT=$hbase_regionserver_handler_count
fi
if [ ! -z $hbase_hfile_block_cache_size ]; then
	HBASE_HFILE_BLOCK_CACHE_SIZE=$hbase_hfile_block_cache_size
fi
if [ ! -z $hbase_regionserver_thread_compaction_large ]; then
	HBASE_REGIONSERVER_THREAD_COMPACTION_LARGE=$hbase_regionserver_thread_compaction_large
fi
if [ ! -z $hbase_regionserver_thread_compaction_small ]; then
	HBASE_REGIONSERVER_THREAD_COMPACTION_SMALL=$hbase_regionserver_thread_compaction_small
fi
if [ ! -z $hbase_regionserver_thread_split ]; then
	HBASE_REGIONSERVER_THREAD_SPLIT=$hbase_regionserver_thread_split
fi

if [[ ! -z $hbase_master_heapsize && $hbase_master_heapsize -gt 0 ]]; then
        HBASE_MASTER_HEAPSIZE=$hbase_master_heapsize
elif [[ ! -z $hbase_master_heapsize_weight && $hbase_master_heapsize_weight -gt 0 ]]; then
        HBASE_MASTER_HEAPSIZE_WEIGHT=$hbase_master_heapsize_weight
else
        HBASE_MASTER_HEAPSIZE=$HBASE_DEFAULT_HEAPSIZE
fi

if [[ ! -z $hbase_regionserver_heapsize && $hbase_regionserver_heapsize -gt 0 ]]; then
        HBASE_REGIONSERVER_HEAPSIZE=$hbase_regionserver_heapsize
elif [[ ! -z $hbase_regionserver_heapsize_weight && $hbase_regionserver_heapsize_weight -gt 0 ]]; then
        HBASE_REGIONSERVER_HEAPSIZE_WEIGHT=$hbase_regionserver_heapsize_weight
else
        HBASE_REGIONSERVER_HEAPSIZE=$HBASE_DEFAULT_HEAPSIZE
fi

if [ ! -z $debug_hbase ]; then
	DEBUG_HBASE=$debug_hbase
fi

if [ ! -z $zk_ticktime ]; then
	ZK_TICKTIME=$zk_ticktime
fi

if [ ! -z $zk_datadir ]; then
        ZK_DATADIR=$zk_datadir
fi

# check parameters

# get the number of logical CPUs.

# get total memory size

# get a list of all mounted disks.

# calculate heap size parameters

# calculate mapred parameters

# end of 'calculate mapred parameters'


# configure hadoop

# configure hdfs

# end of 'configure hdfs'

# configure mapred

# end of 'configure mapred'

echo
echo "Configuring hadoop-env.sh ..."
HADOOP_NAMENODE_JAVAOPTIONS="-Xmx${HADOOP_NAMENODE_HEAPSIZE}m $HADOOP_DEFAULT_NAMENODE_OPTS"
HADOOP_SECONDARYNAMENODE_JAVAOPTIONS="-Xmx${HADOOP_SECONDARYNAMENODE_HEAPSIZE}m $HADOOP_DEFAULT_SECONDARYNAMENODE_OPTS"
HADOOP_DATANODE_JAVAOPTIONS="-Xmx${HADOOP_DATANODE_HEAPSIZE}m $HADOOP_DEFAULT_DATANODE_OPTS"
HADOOP_JOBTRACKER_JAVAOPTIONS="-Xmx${HADOOP_JOBTRACKER_HEAPSIZE}m $HADOOP_DEFAULT_JOBTRACKER_OPTS"
HADOOP_TASKTRACKER_JAVAOPTIONS="-Xmx${HADOOP_TASKTRACKER_HEAPSIZE}m $HADOOP_DEFAULT_TASKTRACKER_OPTS"
if [ $DEBUG_HADOOP = "true" ]
then
	HADOOP_NAMENODE_JAVAOPTIONS="$HADOOP_NAMENODE_JAVAOPTIONS -Xdebug -Xrunjdwp:transport=dt_socket,address=0.0.0.0:${HADOOP_NAMENODE_DEBUG_PORT},server=y,suspend=n"
	HADOOP_SECONDARYNAMENODE_JAVAOPTIONS="$HADOOP_SECONDARYNAMENODE_JAVAOPTIONS -Xdebug -Xrunjdwp:transport=dt_socket,address=0.0.0.0:${HADOOP_SECONDARYNAMENODE_DEBUG_PORT},server=y,suspend=n"
	HADOOP_DATANODE_JAVAOPTIONS="$HADOOP_DATANODE_JAVAOPTIONS -Xdebug -Xrunjdwp:transport=dt_socket,address=0.0.0.0:${HADOOP_DATANODE_DEBUG_PORT},server=y,suspend=n"
	HADOOP_JOBTRACKER_JAVAOPTIONS="$HADOOP_JOBTRACKER_JAVAOPTIONS -Xdebug -Xrunjdwp:transport=dt_socket,address=0.0.0.0:${HADOOP_JOBTRACKER_DEBUG_PORT},server=y,suspend=n"
	HADOOP_TASKTRACKER_JAVAOPTIONS="$HADOOP_TASKTRACKER_JAVAOPTIONS -Xdebug -Xrunjdwp:transport=dt_socket,address=0.0.0.0:${HADOOP_TASKTRACKER_DEBUG_PORT},server=y,suspend=n"
fi


# configure hbase

if [ "$doConfigHBase" = "true" ]
then

echo
echo "Start configuration of HBase."

echo
echo "Configuring hbase-site.xml ..."
echo '<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
/**
 * Copyright 2010 The Apache Software Foundation
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
-->
<configuration>
<property>
  <name>hbase.cluster.distributed</name>
  <value>true</value>
</property>
<property>
  <name>hbase.rootdir</name>
  <value>hdfs://'${HDFS_NAMENODE}'/hbase</value>
</property>
<property>
  <name>hbase.zookeeper.quorum</name>
  <value>'${ZK_QUORUM_SERVERS}'</value>
</property>
<property>
  <name>hbase.master.port</name>
  <value>'${HBASE_MASTER_PORT}'</value>
</property>
<property>
  <name>hbase.master.info.port</name>
  <value>'${HBASE_MASTER_INFO_PORT}'</value>
</property>
<property>
  <name>hbase.regionserver.port</name>
  <value>'${HBASE_REGIONSERVER_PORT}'</value>
</property>
<property>
  <name>hbase.regionserver.info.port</name>
  <value>'${HBASE_REGIONSERVER_INFO_PORT}'</value>
</property>
<property>
  <name>hbase.hregion.max.filesize</name>
  <value>'${HBASE_MAX_FILESIZE}'</value>
</property>
<property>
  <name>hbase.hregion.memstore.flush.size</name>
  <value>'${HBASE_HREGION_MEMSTORE_FLUSH_SIZE}'</value>
</property>
<property>
  <name>zookeeper.session.timeout</name>
  <value>'${HBASE_ZK_SESSION_TIMEOUT}'</value>
</property>
<property>
  <name>hbase.regionserver.handler.count</name>
  <value>'${HBASE_REGIONSERVER_HANDLER_COUNT}'</value>
</property>
<property>
  <name>hfile.block.cache.size</name>
   <value>'${HBASE_HFILE_BLOCK_CACHE_SIZE}'</value>
</property>
<property>
  <name>hbase.regionserver.thread.compaction.large</name>
  <value>'${HBASE_REGIONSERVER_THREAD_COMPACTION_LARGE}'</value>
</property>
<property>
  <name>hbase.regionserver.thread.compaction.small</name>
  <value>'${HBASE_REGIONSERVER_THREAD_COMPACTION_SMALL}'</value>
</property>
<property>
  <name>hbase.regionserver.thread.split</name>
  <value>'${HBASE_REGIONSERVER_THREAD_SPLIT}'</value>
</property>
<property>
  <name>hbase.hregion.memstore.mslab.enabled</name>
  <value>true</value>
</property>
<property>
  <name>hbase.rpc.timeout</name>
  <value>120000</value>
</property> 
</configuration>
' > $HBASE_CONF_DIR/hbase-site.xml || exit $?

echo
echo "Configuring hbase-env.sh ..."
HBASE_MASTER_JAVAOPTIONS="-Xmx${HBASE_MASTER_HEAPSIZE}m $HBASE_DEFAULT_MASTER_OPTS"
HBASE_REGIONSERVER_JAVAOPTIONS="-Xmx${HBASE_REGIONSERVER_HEAPSIZE}m $HBASE_DEFAULT_REGIONSERVER_OPTS"
if [ $DEBUG_HBASE = "true" ]
then
        HBASE_MASTER_JAVAOPTIONS="$HBASE_MASTER_JAVAOPTIONS -Xdebug -Xrunjdwp:transport=dt_socket,address=0.0.0.0:${HBASE_MASTER_DEBUG_PORT},server=y,suspend=n"
        HBASE_REGIONSERVER_JAVAOPTIONS="$HBASE_REGIONSERVER_JAVAOPTIONS -Xdebug -Xrunjdwp:transport=dt_socket,address=0.0.0.0:${HBASE_REGIONSERVER_DEBUG_PORT},server=y,suspend=n"
fi

echo '#
#/**
# * Copyright 2007 The Apache Software Foundation
# *
# * Licensed to the Apache Software Foundation (ASF) under one
# * or more contributor license agreements.  See the NOTICE file
# * distributed with this work for additional information
# * regarding copyright ownership.  The ASF licenses this file
# * to you under the Apache License, Version 2.0 (the
# * "License"); you may not use this file except in compliance
# * with the License.  You may obtain a copy of the License at
# *
# *     http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software
# * distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and
# * limitations under the License.
# */

# Set environment variables here.

# The java implementation to use.  Java 1.6 required.
export JAVA_HOME='"$JAVA_HOME"'

# Extra Java CLASSPATH elements.  Optional.
export HBASE_CLASSPATH='"$HADOOP_CONF_BASE"'/conf

# The maximum amount of heap to use, in MB. Default is 1000.
# export HBASE_HEAPSIZE=8192

# Extra Java runtime options.
# Below are what we set by default.  May only work with SUN JVM.
# For more on why as well as other possible settings,
# see http://wiki.apache.org/hadoop/PerformanceTuning
export HBASE_OPTS="$HBASE_OPTS -ea -XX:+HeapDumpOnOutOfMemoryError -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:CMSInitiatingOccupancyFraction=70"

export HBASE_OPTS="$HBASE_OPTS -XX:+UseParNewGC -XX:NewRatio=1 -XX:NewSize=512m"

# Uncomment below to enable java garbage collection logging.
export HBASE_OPTS="$HBASE_OPTS -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$HBASE_HOME/logs/gc-hbase.log"

# export HBASE_OPTS="$HBASE_OPTS -agentlib:hprof=cpu=samples,depth=20"
# export HBASE_OPTS="$HBASE_OPTS -javaagent:/opt/MonitorAgent.jar=tracedepth=-1,traceoutputfile=/var/log/hbase/threaddump.log,traceinterval=20,buffersize=8192"

# Uncomment and adjust to enable JMX exporting
# See jmxremote.password and jmxremote.access in $JRE_HOME/lib/management to configure remote password access.
# More details at: http://java.sun.com/javase/6/docs/technotes/guides/management/agent.html
#
# export HBASE_JMX_BASE="-Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
export HBASE_MASTER_OPTS="'"$HBASE_MASTER_JAVAOPTIONS"'"
export HBASE_REGIONSERVER_OPTS="'"$HBASE_REGIONSERVER_JAVAOPTIONS"'"
# export HBASE_THRIFT_OPTS="$HBASE_THRIFT_OPTS $HBASE_JMX_BASE -Dcom.sun.management.jmxremote.port=10103"
# export HBASE_ZOOKEEPER_OPTS="$HBASE_ZOOKEEPER_OPTS $HBASE_JMX_BASE -Dcom.sun.management.jmxremote.port=10104"

# File naming hosts on which HRegionServers will run.  $HBASE_HOME/conf/regionservers by default.
# export HBASE_REGIONSERVERS=${HBASE_HOME}/conf/regionservers

# Extra ssh options.  Empty by default.
# export HBASE_SSH_OPTS="-o ConnectTimeout=1 -o SendEnv=HBASE_CONF_DIR"

# Where log files are stored.  $HBASE_HOME/logs by default.
# export HBASE_LOG_DIR=${HBASE_HOME}/logs

# A string representing this instance of hbase. $USER by default.
# export HBASE_IDENT_STRING=$USER

# The scheduling priority for daemon processes.  See "man nice".
# export HBASE_NICENESS=10

# The directory where pid files are stored. /tmp by default.
# export HBASE_PID_DIR=/var/hadoop/pids

# Seconds to sleep between slave commands.  Unset by default.  This
# can be useful in large clusters, where, e.g., slave rsyncs can
# otherwise arrive faster than the master can service them.
# export HBASE_SLAVE_SLEEP=0.1

# Tell HBase whether it should manage its own instance of Zookeeper or not.
export HBASE_MANAGES_ZK=false
' > $HBASE_CONF_DIR/hbase-env.sh

fi
# end of 'configure hbase'


# configure zookeeper

if [ "$doConfigZK" = "true" ]
then

echo
echo "Start configuration of Zookeeper."

echo '# The number of milliseconds of each tick
tickTime='"$ZK_TICKTIME"'
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
dataDir='"$ZK_DATADIR"'
# the port at which the clients will connect
clientPort=2181
maxClientCnxns=0
' > $ZK_CONF_DIR/zoo.cfg

echo 
echo "Adding $ZK_QUORUM_SERVERS to zoo.cfg ..."
zkserverlist=`echo ${ZK_QUORUM_SERVERS} | sed 's:,: :g'`
zkserverindex=0
startzookeeper="false"
HOSTNAME=`hostname`
for zkserver in $zkserverlist
do
	zkserverindex=`expr $zkserverindex + 1`
	echo "server.$zkserverindex=$zkserver:2888:3888" >> $ZK_CONF_DIR/zoo.cfg || exit $?
	if [ $zkserver = $HOSTNAME ]
	then
		echo "Adding file: myid. ID=$zkserverindex ..."
		echo $zkserverindex > ${ZK_DATADIR}/myid || exit $?
		startzookeeper="true"
	fi
done

fi
# end of 'configure zookeeper'
