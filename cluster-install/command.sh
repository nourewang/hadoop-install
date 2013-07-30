if [ -f /etc/edh/role.csv ]; then
    	NODELIST="`cat /etc/edh/role.csv | sed 's/,.*//g'`"
else
	echo "ERROR: Can not found role configuration file /etc/edh/role.csv"
	exit 1
fi

for node in $NODELIST ;do
	echo "$node----"
	ssh -q -i  /etc/edh/edh-id_rsa root@$node $1 
done

