#!/bin/sh

. /etc/edh/installation.conf

#usage: copy_iso [first_check|other]     #copy DVD, first_check to indicate the first disc, only check disc content, not copy.
#usage: copy_iso [first_check|other] isoPath   #copy ISO
first_check=$1
iso_path=$2

#script_dir=`dirname $0`

MOUNT_POINT=/media/cdrom
CDROM_DEV=undef

umask 022

OS_VERSION_COPYISO=$OS_DISTRIBUTOR$OS_RELEASE

SUSE_NAME="sles"

# lsblk command is enabled on the OS rhel6.1 or after , sles11 sp2
# sles11 sp1 and rhel5.X doesn't support lsblk
function is_lsblk_enable {
	no_lsblk_os_list=("sles11.1" "centos5.7" "rhel5.7" "oel5.7")
	for os in ${no_lsblk_os_list[*]}
	do
		if [ "x$OS_VERSION_COPYISO" == "x$os" ]; then
			return 1
		fi
	done
	return 0
}

function detect_cdrom_and_mount {
	#set -e
	if [ "$CDROM_DEV" == "undef" ]; then
		if is_lsblk_enable ; then
			devlist=`lsblk -r -o NAME,RM | grep " 1" | awk '{print $1}'`
			if [ $? -ne 0 ]; then
				devlist=sr0
			fi
		else
			devlist=sr0
		fi
		for device in $devlist
		do
			mount -t iso9660 /dev/$device $MOUNT_POINT >/dev/null
			if [ "$?" == "0" ]; then
				CDROM_DEV=/dev/$device
				return 0
			fi
		done
		echo "ERROR: No DVD detected."
		echo "Please check if your CDROM works well and the DVD has been put into DVD tray.";
		return 32
	else
		mount -t iso9660 $CDROM_DEV $MOUNT_POINT
		return $?
	fi
}

function mount_dvd {
   if [ ! -e $MOUNT_POINT ]; then
      mkdir -p $MOUNT_POINT
   fi
 
   if mount | grep $MOUNT_POINT >/dev/null
   then
	   return 0
   fi

   if [ "x$iso_path" == "x" ]; then
	   echo "Trying to mount CDROM device..."
	   detect_cdrom_and_mount
   else
	   echo "Trying to mount ISO file..."
	   mount -t iso9660 -o loop $iso_path $MOUNT_POINT
   fi
}

function umount_disc {
   if mount | grep $MOUNT_POINT >/dev/null
   then
       #unmount
       echo "Trying to unmount $MOUNT_POINT..."
       while true
       do
          umount $MOUNT_POINT
          if [ $? -eq 0 ]; then
	     echo "$MOUNT_POINT has been unmounted..."
             break
          fi
          sleep 1
       done
   fi
}

function copy_dvd_and_umount {
    set -e
    echo "Copying files..."
    target_dir=$1
    #copy cdrom content
    cd $MOUNT_POINT
    mkdir -p $target_dir
	# copy dvd to $target_dir and don't replace existing files when extracting
    tar cvf - . | (cd $target_dir; tar xpfk -)
    cd - >/dev/null

    umount_disc
    if [ "x$iso_path" == "x" ]; then 
        echo "Please take away your Disc."
    fi
}

function check_dvd {
    check_pkg=$1
    if [ "x$iso_path" == "x" ]; then
	    prompt="Disc"
	    tray="in tray"
    else
	    prompt="ISO Image"
	    tray=""
	    #umount the disc first
	    echo "Begin to check ISO file..."
	    umount_disc 
    fi
    if [ ! "$(ls -A $MOUNT_POINT)" ]; then
	    #mount point is empty
	    mount_dvd
    fi

    if [ "$(ls -A $MOUNT_POINT)" ]; then
    	    #mount point is not empty
	    if ! ls $MOUNT_POINT/$check_pkg >/dev/null 2>&1 ; then
		    umount_disc
		    echo "Invalid $prompt. Please replace with the correct OS Installation $prompt."
		    return 1
	    fi
    else
	    echo "Can't find $prompt mounted."
	    echo "Please use correct OS Installation $prompt $tray."
	    return 2
    fi
    return 0
}

# copy linux os packages and hadoop related packages to ftp dir.
if [ "x$first_check" == "xfirst_check" ]; then
	check_dvd $OS_PACKAGE_DIR/bash-* 
else
	mount_dvd 
	copy_dvd_and_umount $OS_FTP_DIR 
fi
