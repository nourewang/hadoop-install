#!/bin/sh
umask 0022

SCRIPT_DIR=`dirname $0`
CONF_FILE=/etc/edh/installation.conf
IM_CONFIG_LOGDIR=/var/log/edh
OS_DISTRIBUTOR="UNKOWN"

echo -e "\nInit for Apache Hadoop* Software...\n"

if [ $# -eq 2 ]; then
    OS_DISTRIBUTOR=`echo $1 | tr A-Z a-z`
    OS_RELEASE="$2"
elif [ $# -eq 0 ]; then
    if [ ! -f /etc/issue ]; then
        echo "ERROR: Can't find /etc/issue for detecting OS version"
        exit 1
    fi
    ( grep -i "CentOS" /etc/issue > /dev/null ) && OS_DISTRIBUTOR=centos
    ( grep -i "Red[[:blank:]]*Hat[[:blank:]]*Enterprise[[:blank:]]*Linux" /etc/issue > /dev/null ) && OS_DISTRIBUTOR=rhel
    ( grep -i "Oracle[[:blank:]]*Linux" /etc/issue > /dev/null ) && OS_DISTRIBUTOR=oel
    ( grep -i "Asianux[[:blank:]]*Server" /etc/issue > /dev/null ) && OS_DISTRIBUTOR=an
    ( grep -i "SUSE[[:blank:]]*Linux[[:blank:]]*Enterprise[[:blank:]]*Server" /etc/issue > /dev/null ) && OS_DISTRIBUTOR=sles
    ( grep -i "Fedora" /etc/issue > /dev/null ) && OS_DISTRIBUTOR=fedora

    major_revision=`grep -oP '\d+' /etc/issue | sed -n "1,1p"`
    minor_revision=`grep -oP '\d+' /etc/issue | sed -n "2,2p"`
    OS_RELEASE="$major_revision.$minor_revision"
else
    echo "USAGE:
        ./initvar.sh [OS_DISTRIBUTOR OS_RELEASE]
    ";exit 1
fi


case "$OS_DISTRIBUTOR" in
    fedora|rhel|centos|oel|an)
        [[ $major_revision -eq 5 ]] && OS_PACKAGE_DIR=Server && OS_RELEASE_ALIAS=$OS_RELEASE
        [[ $major_revision -eq 5 ]] && [ "$OS_DISTRIBUTOR" == "centos" ] && OS_PACKAGE_DIR=CentOS
        [[ $major_revision -eq 6 ]] && OS_PACKAGE_DIR=Packages && OS_RELEASE_ALIAS=$OS_RELEASE
        [ "$OS_DISTRIBUTOR" == "an" ] && [ "$OS_RELEASE" == "4.2" ] && OS_RELEASE_ALIAS=6.3
	  OS_DISTRIBUTOR_ALIAS=rhel
        FTP_DIR=/var/ftp/pub
	  HTTP_BIN=httpd
	  HTTP_DIR=/var/www/html
        REPO_BIN=yum
        REPO_YES_OPT=-y
        REPO_CLEANALL_OPT=all
        REPO_CONFDIR=/etc/yum.repos.d
        FIREWALL=iptables
        SELINUX=selinux
        PUPPETMASTER_BIN=puppetmaster
        PUPPETMASTER_SCRIPT=none
        NTP_BIN=ntpd
        NTP_CONF_DRIFTFILE=/var/lib/ntp/ntp.drift
        NTP_UPDATE_CMD='ntpdate'

        SSH_PKGS='openssh-server openssh-clients'
        NGINX_PKG=nginx
        ;;
    sles)
	OS_DISTRIBUTOR_ALIAS=sles
	OS_RELEASE_ALIAS=$OS_RELEASE
        OS_PACKAGE_DIR=suse/x86_64
        FTP_DIR=/srv/ftp
	  HTTP_BIN=apache2
        HTTP_DIR=/srv/www/htdocs
        REPO_BIN=zypper
        REPO_YES_OPT=-n
        REPO_CLEANALL_OPT=-a
        REPO_CONFDIR=/etc/zypp/repos.d
        FIREWALL=SuSEfirewall2_setup
        SELINUX=boot.apparmor
        PUPPETMASTER_BIN=puppetmasterd
        PUPPETMASTER_SCRIPT=/usr/lib/deploy/script/puppetmasterd-SLES
        NTP_BIN=ntp
        NTP_CONF_DRIFTFILE=/var/lib/ntp/drift/ntp.drift
        NTP_UPDATE_CMD='sntp -P no -r'

        SSH_PKGS='openssh'
        NGINX_PKG=nginx-1.0
	 # Modify the drbd-km version based on the kernel
	kernel_version=`uname -r | tr -s '-' '_'`
        sed -i "s/drbd,drbd,drbd-km-.*/drbd,drbd,drbd-km-$kernel_version/g" /usr/lib/deploy/puppet/default/pkg-service-info/idh-related/SLES/related-pkg.csv > /dev/null 2>&1
        ;;
    *)
        echo -e "ERROR: Unsupported Operating System."
        echo -e "Supported OS are:"
        echo -e "  RHEL, CENTOS, OEL, SLES"
        exit 1
        ;;
esac

[ ! -d /etc/edh ] && mkdir /etc/edh -p
rm -f $CONF_FILE

param_arr=( OS_DISTRIBUTOR OS_RELEASE OS_DISTRIBUTOR_ALIAS OS_RELEASE_ALIAS IM_CONFIG_LOGDIR OS_PACKAGE_DIR FTP_DIR EDH_FTP_DIR OS_FTP_DIR HTTP_BIN HTTP_DIR REPO_BIN REPO_YES_OPT REPO_CLEANALL_OPT REPO_CONFDIR FIREWALL SELINUX PUPPETMASTER_BIN PUPPETMASTER_SCRIPT NTP_BIN NTP_CONF_DRIFTFILE NTP_UPDATE_CMD SSH_PKGS NGINX_PKG )

for param_name in ${param_arr[@]}; do
    eval param_value=\$$param_name
    echo "export $param_name='$param_value'" >> $CONF_FILE
done

>> $CONF_FILE

