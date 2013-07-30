source $SCRIPTPATH/setenv.sh
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 -o PasswordAuthentication=no $1 hostname  2>/dev/null 
