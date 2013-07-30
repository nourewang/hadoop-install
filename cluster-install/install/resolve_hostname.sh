if [ "$1" == "" ];then
	echo "./hostnameresolve.sh [hostname]"
	exit 1
fi

hostname=$1
ping_output=`ping -c 1 -w 2 $hostname 2>&1`
ping_result=$?

if [ $ping_result -eq 2 ];then
	if [ "`echo $ping_output|grep $hostname`"!="" ];then
		echo "Cannot resolve $hostname"
		exit 1
	else 
		echo "Other error in system:$ping_output"
		exit 1
	fi
else
	echo "$hostname is resolved successfully"
fi
