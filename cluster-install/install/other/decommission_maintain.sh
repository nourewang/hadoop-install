source $SCRIPTPATH/setenv.sh
hostname=$1
hostip=$2
while [ "true" == "true" ]; 
do 
   res=`ssh $hostname 'su -s /bin/bash hdfs -c "hadoop dfsadmin -report | grep '$hostip':"'`
   if [ "$res" == "" ]; then
       break;
   fi 
   res=`ssh $hostname 'su -s /bin/bash hdfs -c "hadoop dfsadmin -report | grep -A 2 '$hostip' | grep Decommissioned"'`
   if [ "$res" != "" ]; then 
       break
   fi
   sleep 10
done

ssh $hostname service hadoop-datanode stop
ssh $hostname 'su -s /bin/bash hdfs -c "hadoop dfsadmin -recommissionNodes '$hostip'"'
ssh $hostname 'su -s /bin/bash hdfs -c "hadoop dfsadmin -refreshNodes"'
