#!/bin/sh

. /etc/edh/installation.conf

if [ $# != 1 ]; then
	echo "USAGE: 
	./config_yum_server.sh selected_ip"
	exit 1
fi

umask 022

script_dir=`dirname $0`

server_ip=$1

function clean_repo_file {
	echo -e "\nAs recommended, the repo files in /etc/yum.repo.d need to be removed."
	echo "Please make sure these files are correct if you want to keep them."

	continue_flag="undef"
	while [ "$continue_flag" != "yes" -a "$continue_flag" != "no" ]
	do
		read -p "Type yes to remove the repo files or no to keep them...[yes|no]: " continue_flag
		if [ "$continue_flag" == "no" ]; then
			return 0
		fi
	done

	cd $REPO_CONFDIR
	if ls *.repo >/dev/null 2>&1; then
		for file in `ls *.repo`
		do
			mv $file $file.bak -f
		done
	fi
	cd - >/dev/null
}

function select_os_repo {
	echo -e "\nA Linux OS yum repository is needed for Intel Hadoop Installation and cluster management."
	echo -e "The file DEP_OS_PKG at the root of this installation folder, shows the list of dependent Linux OS packages.\n"
	create_flag="undef"
	while [ "$create_flag" != "yes" -a "$create_flag" != "no" ]
	do
		read -p "Type yes to create yum repository on local host or no to using an existing repository...[yes|no|exit]: " create_flag
		if [ "$create_flag" == "exit" ]; then
			exit 1
		fi
		if [ "$create_flag" == "yes" ]; then
			# copy dvd to the management node.
			$script_dir/copy_dvd.sh
			if [ "$?" != "0" ]; then
				exit 1
			fi
			
			echo -e "[os]\nname = Linux OS packages\nbaseurl = file://$OS_FTP_DIR\nproxy = _none_\ngpgcheck = 0" > $REPO_CONFDIR/os.repo
			# install vsftpd and createrepo which will be used for creating yum repository
			yum clean all > /dev/null
			echo "Installing vsftpd and createrepo for building repository..."
			yum install vsftpd createrepo -y -q
			echo "Creating Linux OS repository..."
			createrepo $OS_FTP_DIR
			echo -e "[os]\nname = Linux OS packages\nbaseurl = ftp://$server_ip/pub/os\nproxy = _none_\ngpgcheck = 0" > $REPO_CONFDIR/os.repo
		fi
		if [ "$create_flag" == "no" ]; then
			read -p "Please input URL of the existing Linux OS repository: " repourl
			echo -e "[os]\nname = Linux OS packages\nbaseurl = $repourl\nproxy = _none_\ngpgcheck = 0" > $REPO_CONFDIR/os.repo
			yum clean all > /dev/null 2>&1
			if ! yum install vsftpd -q -y; then
				echo "Couldn't find vsftpd packages. Given Linux OS repository unavailable! "
				create_flag="undef"
			fi
		fi
	done
}

#stop selinux and iptables
#echo "Disable selinux and iptables..."
service iptables stop >/dev/null 2>&1
chkconfig iptables off >/dev/null 2>&1
sed -i "s/.*SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config >/dev/null 2>&1
setenforce 0 >/dev/null 2>&1

clean_repo_file

select_os_repo

#start vsftpd, if previouslly running, stop it first
if service vsftpd status >/dev/null 2>&1; then
	service vsftpd stop
fi
service vsftpd start
chkconfig --add vsftpd >/dev/null
chkconfig vsftpd on >/dev/null

# add edh.repo on the management node for edh repository.
os_version="$OS_DISTRIBUTOR_ALIAS$OS_RELEASE_ALIAS"
echo "
[edh]
name = edh and related packages
baseurl = ftp://$server_ip/pub/edh
proxy = _none_
gpgcheck = 0
" > $REPO_CONFDIR/edh.repo

if [ -d "$FTP_DIR/os_related/$os_version" ]; then
  echo "
[ospkg]
name = related os packages
baseurl = ftp://$server_ip/pub/os_related/$os_version
proxy = _none_
gpgcheck = 0
" >> $REPO_CONFDIR/edh.repo
fi
