#!/bin/bash

#CREATE USER 'USERNAME'@'xxx.xxx.xxx.xxx' IDENTIFIED BY 'xxxxxxxxxx';
#GRANT SELECT, LOCK TABLES, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'USERNAME'@'xxx.xxx.xxx.xxx';

MysqlHosts=( HOST1 HOST2 HOST3 HOST4 )

bckPath='/YOUR_BACKUP_PATH/DataBase'
bckDate=$(date '+%Y-%m-%d')
DBuser='USERNAME'
DBpass='PASSWORD'

for DBhost in "${MysqlHosts[@]}"
do
   if [ ! -d $bckPath/$DBhost ]
   then
     mkdir $bckPath/$DBhost
   fi

   if [ ! -x $bckPath/$DBhost ]
   then
     echo -e "\n[Error] Unable to access $bckPath/$DBhost... exit\n"
     exit 1;
   fi

   for db in $( mysql -h $DBhost --password=$DBpass -u $DBuser -e 'show databases;' | head -1000 | egrep -Ev 'information_schema|mysql|Database|performance_schema')
   do
     start=$(date '+%s')
     echo -e "[$DBhost] - $db: executing backup... \c"
     bckFile=$bckPath/$DBhost/$DBhost-$bckDate-$db.sql
     mysqldump -h $DBhost -u $DBuser --password=$DBpass $db > $bckFile
     stop=$(date '+%s')
     echo -e "Completed in: $((stop-start)) s"
     bzip2 $bckFile
   done
done
