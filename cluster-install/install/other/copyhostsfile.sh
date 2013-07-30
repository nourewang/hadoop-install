source $SCRIPTPATH/setenv.sh
scp /etc/hosts root@$1:/etc/   >/dev/null 2>&1
