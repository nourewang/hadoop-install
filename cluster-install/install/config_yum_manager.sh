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

function select_repo {
	REPO=$1
	echo -e "\nA $REPO yum repository is needed for Intel Hadoop Installation and cluster management."
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
			
			# install vsftpd and createrepo which will be used for creating yum repository
			yum clean all > /dev/null
			echo "Installing vsftpd and createrepo for building repository..."
			yum install vsftpd createrepo -y -q
			echo "Creating $REPO repository..."
			createrepo $FTP_DIR/$REPO
			echo -e "[$REPO]\nname = $REPO packages\nbaseurl = ftp://$server_ip/pub/$REPO\nproxy = _none_\ngpgcheck = 0" > $REPO_CONFDIR/$REPO.repo
		fi
		if [ "$create_flag" == "no" ]; then
			read -p "Please input URL of the existing $REPO repository: " repourl
			echo -e "[$REPO]\nname = $REPO packages\nbaseurl = $repourl\nproxy = _none_\ngpgcheck = 0" > $REPO_CONFDIR/$REPO.repo
			yum clean all > /dev/null 2>&1
			if ! yum install vsftpd -q -y; then
				echo "Couldn't find vsftpd packages. Given $REPO repository unavailable! "
				create_flag="undef"
			fi
		fi
	done
}

clean_repo_file

select_repo os

select_repo edh

#start vsftpd, if previouslly running, stop it first
if service vsftpd status >/dev/null 2>&1; then
	service vsftpd stop
fi
service vsftpd start
chkconfig --add vsftpd >/dev/null
chkconfig vsftpd on >/dev/null
