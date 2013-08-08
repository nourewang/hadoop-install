hadoop-install
==============


## Overview

	.
	├── all-in-one
	│   ├── conf-template
	│   ├── format.sh
	│   ├── install.sh
	│   ├── postgres-fedora19.sh
	│   ├── postgresql-9.1-901.jdbc4.jar
	│   ├── readme.txt
	│   ├── start.sh
	│   ├── temp.sh
	│   └── uninstall.sh
	├── cluster-install
	│   ├── command.sh
	│   ├── conf-template
	│   ├── edh
	│   ├── format.sh
	│   ├── install
	│   ├── install.sh
	│   ├── start.sh
	│   └── temp.sh
	└── README.md

* all-in-one: install hadoop in one node
* cluster-install: install hadoop in a cluster

## How to use

* all-in-one

open install.sh and modify repo's baseurl:

	echo "[cloudera-cdh4]" >/etc/yum.repos.d/cloudera-cdh4.repo
	echo "name=cdh4" >>/etc/yum.repos.d/cloudera-cdh4.repo
	echo "baseurl=ftp://192.168.56.101/pub/cdh/4.3.0/" >>/etc/yum.repos.d/cloudera-cdh4.repo
	echo "gpgcheck = 0" >>/etc/yum.repos.d/cloudera-cdh4.repo

And then run this commands:

	[root@node1 all-in-one]# sudo sh install.sh
	[root@node1 all-in-one]# sudo sh postgres-fedora19.sh 

Wait several seconds,run jps command and you will see:

	[root@node1 ~]# jps
	30455 RunJar
	31060 HRegionServer
	30539 RunJar
	29874 DataNode
	28843 NameNode
	31160 Jps
	29989 ResourceManager
	30380 JobHistoryServer
	30844 QuorumPeerMain
	1810 SecondaryNameNode
	30246 NodeManager

## Change

## TODO



 
