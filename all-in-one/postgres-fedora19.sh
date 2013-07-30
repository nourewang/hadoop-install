#!/bin/bash

if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi

pkill -9 postgres

yum install postgresql-server postgresql-jdbc -y >/dev/null
chkconfig postgresql on

rm -rf /var/lib/pgsql/data
rm -rf /var/run/postgresql/.s.PGSQL.5432

service postgresql initdb

sed -i '/listen/s/#//;/listen/s/localhost/*/' /var/lib/pgsql/data/postgresql.conf
sed -i "s|#standard_coffforming_strings = on|standard_conforming_strings = off|g" /var/lib/pgsql/data/postgresql.conf
echo "local    all             all             		               trust" > /var/lib/pgsql/data/pg_hba.conf
echo "host     all             all             0.0.0.0/0	               trust" >> /var/lib/pgsql/data/pg_hba.conf

sudo cat /var/lib/pgsql/data/postgresql.conf | grep -e listen -e standard_conforming_strings

rm -rf /usr/lib/hive/lib/postgresql-jdbc.jar
ln -s /usr/share/java/postgresql-jdbc.jar /usr/lib/hive/lib/postgresql-jdbc.jar

su -c "cd ; /usr/bin/pg_ctl start -w -m fast -D /var/lib/pgsql/data" postgres
su -c "cd ; /usr/bin/psql --command \"create user hiveuser with password 'redhat'; \" " postgres
su -c "cd ; /usr/bin/psql --command \"CREATE DATABASE metastore owner=hiveuser;\" " postgres
su -c "cd ; /usr/bin/psql --command \"GRANT ALL privileges ON DATABASE metastore TO hiveuser;\" " postgres
su -c "cd ; /usr/bin/psql -U hiveuser -d metastore -f /usr/lib/hive/scripts/metastore/upgrade/postgres/hive-schema-0.10.0.postgres.sql" postgres
su -c "cd ; /usr/bin/pg_ctl restart -w -m fast -D /var/lib/pgsql/data" postgres

