source $SCRIPTPATH/setenv.sh
# $1 tar ball path
host=$1
fileDir=$2
file=$3

parse_keytabfile(){
   filename=$1
   principals=`klist -ek $filename |grep -v "Keytab name:"| grep -v "KVNO"|grep '/'`
   for p in $principals
     do
     if [[ "$p" == */* ]]
     then
         echo "info:"$p
     fi
   done
}
      if [[ "$file" == namenode*.keytab ]]
      then
        scp $fileDir/$file root@${host}:/etc/namenode.keytab
        if [ $? == 0 ]; then
          ssh $host chown hdfs:hadoop /etc/namenode.keytab
          parse_keytabfile $fileDir/$file
        fi
      fi

      if [[ "$file" == jobtracker*.keytab ]]
      then
        scp $fileDir/$file root@${host}:/etc/jobtracker.keytab
        if [ $? == 0 ]; then
          ssh $host chown mapred:hadoop /etc/jobtracker.keytab
          parse_keytabfile $fileDir/$file
        fi
      fi

      if [[ "$file" == HTTP*.keytab ]]
      then
        scp $fileDir/$file root@${host}:/etc/http.keytab
        if [ $? == 0 ]; then
          ssh $host chmod 444 /etc/http.keytab
          parse_keytabfile $fileDir/$file
        fi
      fi

      if [[ "$file" == hdfs*.keytab ]]
      then
        scp $fileDir/$file root@${host}:/etc/hdfs.keytab
        if [ $? == 0 ]; then
          ssh $host chown hdfs:hadoop /etc/hdfs.keytab
          parse_keytabfile  $fileDir/$file
        fi
      fi

      if [[ "$file" == mapred*.keytab ]]
      then
        scp  $fileDir/$file root@${host}:/etc/mapred.keytab
        if [ $? == 0 ]; then
          ssh $host chown mapred:hadoop /etc/mapred.keytab
          parse_keytabfile  $fileDir/$file
        fi
      fi

      if [[ "$file" == zookeeper*.keytab ]]
      then
        scp  $fileDir/$file root@${host}:/etc/zookeeper.keytab
        if [ $? == 0 ]; then
          ssh $host chown zookeeper:hadoop /etc/zookeeper.keytab
          parse_keytabfile  $fileDir/$file
        fi
      fi

      if [[ "$file" == hbase*.keytab ]]
      then
        scp  $fileDir/$file root@${host}:/etc/hbase.keytab
        if [ $? == 0 ]; then
          ssh $host chown hbase:hadoop /etc/hbase.keytab
          parse_keytabfile  $fileDir/$file
        fi
      fi

      if [[ "$file" == hive*.keytab ]]
      then
        scp  $fileDir/$file root@${host}:/etc/hive.keytab
        if [ $? == 0 ]; then
          ssh $host chown hive:hadoop /etc/hive.keytab
          parse_keytabfile  $fileDir/$file
        fi
      fi

      if [[ "$file" == oozie*.keytab ]]
      then
        scp  $fileDir/$file root@${host}:/etc/oozie.keytab
        if [ $? == 0 ]; then
          ssh $host chown oozie:hadoop /etc/oozie.keytab
          parse_keytabfile  $fileDir/$file
        fi
      fi

  rm -rf $file
