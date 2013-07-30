source $SCRIPTPATH/setenv.sh
host=$1
ssh $host crm resource stop ip_hadoop 
ssh $host crm resource stop fs_hadoop
ssh $host crm resource stop ms_drbd_hadoop
ssh $host crm resource start ms_drbd_hadoop
ssh $host crm resource start fs_hadoop
ssh $host crm resource start ip_hadoop
