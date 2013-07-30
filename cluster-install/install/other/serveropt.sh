source $SCRIPTPATH/setenv.sh
CurrentPath=$(cd "$(dirname "$0")"; pwd)
if [ "$3" != "restartserver" ]; then 
    bash ${CurrentPath}/services_web.sh $1 $2 $3 $4 $5
else 
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 $1 "shutdown -r now"
fi 
