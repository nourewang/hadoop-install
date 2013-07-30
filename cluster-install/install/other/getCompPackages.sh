source $SCRIPTPATH/setenv.sh
#1 component name
comp=$1
for package in `rpm -qa|grep $comp`
do
  echo $package
done
