# $1 compName
# $2 tar ball path
# $3 backup  dir
compName=$1
newRPMDIR=$2
backupDIR=$3
fileName=$4

script_dir=`dirname $0`
. /etc/intelcloud/installation.conf

if [ "$OS_DISTRIBUTOR" == "sles" ]; then 
  IDHBaseDIR=/srv/ftp/idh
  IDHRepoDIR=/srv/ftp/idh/hadoop/
else
  IDHBaseDIR=/var/ftp/pub/idh
  IDHRepoDIR=/var/ftp/pub/idh/hadoop/
fi

#backup the old rpms
if [ -d $IDHRepoDIR/$compName ]
then
  mv $IDHRepoDIR/$compName $backupDIR/
fi

if [[  "$fileName" == *.tar ]] ;then
  tar -xvf $newRPMDIR/$fileName --directory=$newRPMDIR
elif [[ "$fileName" == *.tar.gz ]] ;then
  tar -zxvf $newRPMDIR/$fileName --directory=$newRPMDIR
elif [[ "$fileName" == *.zip ]] ;then
  unzip $newRPMDIR/$fileName -d $newRPMDIR
fi

#mv the new rpms to the ftp and update the yum repo
rm -rf $newRPMDIR/$fileName
mv $newRPMDIR/* $IDHRepoDIR/

#update the repo
createRepoResult=true
createrepo --update $IDHBaseDIR 
if [ $? != 0 ]
then 
  createRepoResult=false
fi
createrepo --update -g hadoop-groups.xml $IDHBaseDIR
if [ $? != 0 ]
then 
  createRepoResult=false
fi

rm -rf $newRPMDIR/*

