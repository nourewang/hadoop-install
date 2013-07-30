source $SCRIPTPATH/setenv.sh
#Accept two params
#$1 is the modified hostname
#$2 is the modified rolestr, like roles=nn,jt
ROLECONFHOME=/usr/lib/intelcloud
FILENAME=myrole_"$1"
echo "$2" > /tmp/$FILENAME 2>/dev/null
scp /tmp/$FILENAME root@$1:$ROLECONFHOME/myrole 2>/dev/null
echo "$?"
if [ -f /tmp/$FILENAME ]
then
	rm -rf /tmp/$FILENAME
fi
