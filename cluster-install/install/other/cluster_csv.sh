source $SCRIPTPATH/setenv.sh
cd $SCRIPTPATH
cd ../classes 
java -agentpath:../../../../../bin/libagent.so -cp . com.intelcloud.webui.server.idhconfig.ClusterController $1 $2 $3
