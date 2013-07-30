source $SCRIPTPATH/setenv.sh
host=$1
ssh $host "echo IM_ROLES:;cat /usr/lib/intelcloud/myroles 2>/dev/null;echo;echo IM_MEM:;cat /proc/meminfo 2>/dev/null | grep 'MemTotal'"
