source $SCRIPTPATH/setenv.sh
PuppetConfigPath=/etc/puppet/config
host=$1
csvfile=$PuppetConfigPath/hdfs-site-$host.csv
datanode_dir_attr_name=dfs.data.dir
data_dir_str=`sed -n '/^'"$datanode_dir_attr_name",'/p' $csvfile`
data_dirs=`echo "$data_dir_str" | awk 'BEGIN{FS=","}{for (i=2; i<=NF; i++) print $i}'`
ssh $host service hadoop-datanode stop
sleep 3
for data_dir in $data_dirs
do
  ssh $host "su -s /bin/bash hdfs -c \"rm -rf $data_dir/*\""
done
