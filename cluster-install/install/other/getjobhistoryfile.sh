source $SCRIPTPATH/setenv.sh
#$1 jobtracker
#$2 jobid
JOBTRACKER=$1
JOBHISTORYDIR=$2
JOBID=$3
WEBSERVERJOBHISTORY=$4
if [ -d $WEBSERVERJOBHISTORY ]
then
 echo "do nothing"  2>/dev/null 1>&2
else	
  mkdir -p $WEBSERVERJOBHISTORY
fi
for file in `ssh $JOBTRACKER find $JOBHISTORYDIR -name \"${JOBID}_*\" `
do
  scp $JOBTRACKER:$file $WEBSERVERJOBHISTORY 2>/dev/null 1>&2
done

for file in `ls $WEBSERVERJOBHISTORY | grep $JOBID`
do
 if [[ "$file" == *.xml ]]
 then
   echo "skip the config file" 2>/dev/null 1>&2
 else
   echo $file
 fi
done
