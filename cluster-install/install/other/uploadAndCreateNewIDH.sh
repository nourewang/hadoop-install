source $SCRIPTPATH/setenv.sh
# $1 compName
# $2 tar ball path
# $3 backup  dir
deployhome=/usr/lib/deploy/script/upgrade/
compName=$1
newRPMDIR=$2
backupDIR=$3
fileName=$4

sh $deployhome/uploadAndCreateNewIDH.sh $compName $newRPMDIR $backupDIR $fileName 2>&1 >/dev/null
