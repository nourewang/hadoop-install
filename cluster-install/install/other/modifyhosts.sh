source $SCRIPTPATH/setenv.sh
#add a hostname and ipaddress mapping to /etc/hosts
#accept two params
#$1 is the hostname
#$2 is the ipaddress
sed -i '/[[:space:]]\{1,\}'$1'[[:space:]]*$/d' /etc/hosts
sed -i '/[[:space:]]*'$2'[[:space:]]\{1,\}.*$/d' /etc/hosts
echo "$2	$1" >>/etc/hosts
