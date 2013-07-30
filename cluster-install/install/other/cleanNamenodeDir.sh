source $SCRIPTPATH/setenv.sh
PuppetConfigPath=/etc/puppet/config
host=$1
csvfile=$PuppetConfigPath/hdfs-site-$host.csv
namenode_dir_attr_name=dfs.name.dir
name_dir_str=`sed -n '/^'"$namenode_dir_attr_name",'/p' $csvfile`
name_dirs=`echo "$name_dir_str" | awk 'BEGIN{FS=","}{for (i=2; i<=NF; i++) print $i}'`
ssh $host service hadoop-namenode stop
sleep 3
if [ "$name_dirs" == "" ];then
    name_dirs="/hadoop/drbd/hadoop_image /hadoop/hadoop_image_local"
fi
for name_dir in $name_dirs
do
  ssh $host "
	if [ -d $name_dir ]; then
		su -s /bin/bash hdfs -c \"rm -rf $name_dir/*\"
                if [ "$?" != "0" ];then
                    echo "[IM_CONFIG_ERROR]: Cannot format directory $name_dir !"
                    exit 1
                fi
        else 
               echo "[IM_CONFIG_ERROR]: Directory $name_dir does not exist! "
               exit 1
        fi
  "
  if [ "$?" != "0" ];then
     exit 1
  fi
done
