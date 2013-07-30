#!/bin/sh
script_dir=`dirname $0`

. /etc/edh/installation.conf

MOUNT_POINT=/media/cdrom
CDROM_DEV=undef

umask 022

# Default value is for Centos 6
PACKAGE_DIR="Packages"
if [ ${OS_RELEASE:0:1} == "5" ]
then
    PACKAGE_DIR="CentOS"
fi
if [ ${OS_RELEASE:0:1} == "6" ]
then
    PACKAGE_DIR="Packages"
fi 

function detect_cdrom_and_mount {
	if [ "$CDROM_DEV" == "undef" ]; then
		for device in `lsblk -r -o NAME,RM | grep " 1" | awk '{print $1}'`
		do
			mount -t iso9660 /dev/$device $MOUNT_POINT >/dev/null
			if [ "$?" == "0" ]; then
				CDROM_DEV=/dev/$device
				return 0
			fi
		done
		echo "ERROR: No DVD detected. Please check if your CDROM works well and the DVD has been put into DVD tray.";
		return 32
	else
		mount -t iso9660 $CDROM_DEV $MOUNT_POINT >/dev/null
		return $?
	fi
}

function mount_dvd {
   msg=$1
   if [ ! -e $MOUNT_POINT ]; then
      mkdir -p $MOUNT_POINT
   fi
 
   sucess_flag=1
   while [ "$sucess_flag" != "0" ]
   do
	 if `which lsblk >/dev/null 2>&1` 
	 then
	   read -p "Please input the path of the ISO. For using DVD, please put $msg into DVD tray and press Enter: " iso_path   
	   if [ "x$iso_path" == "x" ]; then
       	     detect_cdrom_and_mount
	     sucess_flag=$?
           else
             mount -t iso9660 -o loop $iso_path $MOUNT_POINT
	     sucess_flag=$?
           fi
	 else
	   read -p "Please input the path of the $msg ISO: " iso_path   
	   if [ "x$iso_path" != "x" ]; then
             mount -t iso9660 -o loop $iso_path $MOUNT_POINT
	     sucess_flag=$?
           fi
	 fi
   done
}

function copy_dvd_and_umount {
    target_dir=$1
    #copy cdrom content
    cd $MOUNT_POINT
    mkdir -p $target_dir
	# copy dvd to $target_dir and don't replace existing files when extracting
    tar cvf - . | (cd $target_dir; tar xpfk -)
    cd -

    #unmount
    while true
    do
        sleep 5
        umount $MOUNT_POINT
        if [ $? -eq 0 ]; then
            break
        fi
    done
}

function copy_dvd {
    check_pkg=$1
    msg=$2
    target_dir=$3
    while ! ls $MOUNT_POINT/$check_pkg >/dev/null 2>&1
    do
        if mount | grep $MOUNT_POINT >/dev/null
        then
            umount $MOUNT_POINT
        fi
	mount_dvd "$msg"
    done

    copy_dvd_and_umount $target_dir

}

echo ""
echo "This program will copy the Linux Operation System Installation DVDs to hard disk."
echo "With these files, a YUM repository and PXE server can be set up to install other machines in this LAN."
echo "You must run this program as root user."
echo ""


echo "Current Operation System version is `echo $OS_DISTRIBUTOR | tr a-z A-Z` $OS_RELEASE"
# copy linux os packages and hadoop related packages to ftp dir.
if [ ! -e $OS_FTP_DIR/$PACKAGE_DIR ]; then
	copy_dvd $PACKAGE_DIR/bash-*.rpm "Linux Operation System Installation DVD 1" $OS_FTP_DIR
    while true 
    do
        echo ""
        read -p "Do you want to copy another Linux Operation System Installation DVD? (yes or no)" answer
        if [ "$answer" = "yes" ]; then
           mount_dvd "Linux Operation System Installation DVD"
           copy_dvd_and_umount $OS_FTP_DIR 
        else
	   break
        fi
    done
fi
