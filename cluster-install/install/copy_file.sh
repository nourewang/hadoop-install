#!/bin/sh

. /etc/edh/installation.conf

current_dir=`dirname $0`


function copy_files {
	cd $current_dir/../
	tar zxf cdh4.3.0-centos6.tar.gz
	cd $current_dir/install

	echo "Deploy Hadoop and related packages to the $REPO_BIN repository..."
	if [ ! -d $FTP_DIR ]; then
		mkdir -p $FTP_DIR
	fi
	
	rm -rf $FTP_DIR/edh
	mv -f $current_dir/../cdh/4.3.0 $FTP_DIR/edh

	if [ -d $current_dir/../os_related ]; then
		\cp -r $current_dir/../os_related $FTP_DIR
	fi

	echo " "
	echo "Files are successfully copied."
}

echo -e "\nCopy Files...\n"

copy_files
