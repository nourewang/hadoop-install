. /etc/edh/installation.conf

if [ $REPO_BIN == "yum" ]; then
	echo "Clean yum cache:"
	yum clean  all -y 2>&1
elif [ $REPO_BIN == "zypper" ]; then
	echo "Clean zypper cache"
 	zypper clean 2>&1	
fi
