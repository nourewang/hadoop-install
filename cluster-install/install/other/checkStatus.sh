source $SCRIPTPATH/setenv.sh
#!/bin/bash
#$1 service name
service $1 status
exit $? 
