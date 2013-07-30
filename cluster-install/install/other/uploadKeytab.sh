source $SCRIPTPATH/setenv.sh
# $1 tar ball path
tarDir=$1
fileName=$2

cd $tarDir

if [[  "$fileName" == *.tar ]] ;then
  mv -f *.tar keytabs.tar
  fileName="keytabs.tar"
  tar -xvf $tarDir/$fileName --directory=$tarDir
elif [[ "$fileName" == *.tar.gz ]] ;then
  mv -f *.tar.gz keytabs.tar.gz
  fileName="keytabs.tar.gz"
  tar -zxvf $tarDir/$fileName --directory=$tarDir
elif [[ "$fileName" == *.zip ]] ;then
  mv -f *.zip keytabs.zip
  fileName="keytabs.zip"
  unzip $tarDir/$fileName -d $tarDir
fi

rm -rf $fileName

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

for rootDIR in  `ls .`
do
  cd $rootDIR 
  for host in `ls .`
  do
    for file in `ls $host`
    do
      echo "file name is :"$file
      
      if [[ "$file" == namenode*.keytab ]]
      then
        scp $host/$file root@${host}:/etc/namenode.keytab
        if [ $? == 0 ]; then
          ssh $host chown hdfs:hadoop /etc/namenode.keytab
          parse_keytabfile $host/$file
        fi
      fi

      if [[ "$file" == jobtracker*.keytab ]]
      then
        scp $host/$file root@${host}:/etc/jobtracker.keytab
        if [ $? == 0 ]; then
          ssh $host chown mapred:hadoop /etc/jobtracker.keytab
          parse_keytabfile $host/$file
        fi
      fi
      
      if [[ "$file" == HTTP*.keytab ]] || [[ "$file" == http*.keytab ]]
      then
        scp $host/$file root@${host}:/etc/http.keytab
        if [ $? == 0 ]; then
          ssh $host chmod 444 /etc/http.keytab
          parse_keytabfile $host/$file
        fi
      fi

      if [[ "$file" == hdfs*.keytab ]]
      then
        scp $host/$file root@${host}:/etc/hdfs.keytab
        if [ $? == 0 ]; then
          ssh $host chown hdfs:hadoop /etc/hdfs.keytab
          parse_keytabfile $host/$file
        fi
      fi

      if [[ "$file" == mapred*.keytab ]]
      then
        scp $host/$file root@${host}:/etc/mapred.keytab
        if [ $? == 0 ]; then
          ssh $host chown mapred:hadoop /etc/mapred.keytab
          parse_keytabfile $host/$file
        fi
      fi

      if [[ "$file" == zookeeper*.keytab ]]
      then
        scp $host/$file root@${host}:/etc/zookeeper.keytab
        if [ $? == 0 ]; then
          ssh $host chown zookeeper:hadoop /etc/zookeeper.keytab
          parse_keytabfile $host/$file
        fi
      fi

      if [[ "$file" == hbase*.keytab ]]
      then
        scp $host/$file root@${host}:/etc/hbase.keytab
        if [ $? == 0 ]; then
          ssh $host chown hbase:hadoop /etc/hbase.keytab
          parse_keytabfile $host/$file
        fi
      fi

      if [[ "$file" == hive*.keytab ]]
      then
        scp $host/$file root@${host}:/etc/hive.keytab
        if [ $? == 0 ]; then
          ssh $host chown hive:hadoop /etc/hive.keytab
          parse_keytabfile $host/$file
        fi
      fi

      if [[ "$file" == oozie*.keytab ]]
      then
        scp $host/$file root@${host}:/etc/oozie.keytab
        if [ $? == 0 ]; then
          ssh $host chown oozie:hadoop /etc/oozie.keytab
          parse_keytabfile $host/$file
        fi
      fi

    done
  done
  cd - 
  rm -rf $rootDIR
done
