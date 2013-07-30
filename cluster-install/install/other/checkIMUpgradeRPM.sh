source $SCRIPTPATH/setenv.sh
file=$1
if [ -f "$file" ];then
    exit 0
else
    exit 1
fi
