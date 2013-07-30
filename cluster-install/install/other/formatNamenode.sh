source $SCRIPTPATH/setenv.sh
NameNode=$1
ssh $NameNode "
su -s /bin/bash hdfs -c 'yes Y |hadoop namenode -format >> /tmp/nn.format.log 2>&1' 2>/dev/null
"
