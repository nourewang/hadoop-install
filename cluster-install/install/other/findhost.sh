#!/usr/bin/expect
set host [lindex $argv 0]
set password [lindex $argv 1]
spawn ssh -i /etc/intelcloud/idh-id_rsa root@$host "echo \"Hostname: \" `hostname 2>/dev/null`"
expect {
-nocase "password:" {send "$password\r"}
timeout {exit 1}
}
expect eof

