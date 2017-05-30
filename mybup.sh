#!/bin/bash
#------------------------------------------------------------------------------#
# mybup
# Backup all databases from a pool of hosts
# me@mrw0lfc.com
#------------------------------------------------------------------------------#

# Configure a read-only user on the database server with these commands
# CREATE USER 'USERNAME'@'xxx.xxx.xxx.xxx' IDENTIFIED BY 'xxxxxxxxxx';
# GRANT SELECT, LOCK TABLES, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'USERNAME'@'xxx.xxx.xxx.xxx';

#--- CONFIG ---------------------------
DBhost=( HOST1 HOST2 HOST3 HOST4 )
DBuser='USERNAME'
DBpass='PASSWORD'
bckPath='/YOUR_BACKUP_PATH/'
bckDays='30' #Delete backup older then 'bckDays' days
#--------------------------------------

#--- MAIN CODE ------------------------
bckDate=$(date '+%Y-%m-%d_%H%M')
rm -f $bckPath/mybup.log &> /dev/null

if [ ! -d $bckPath/logs ]
then
  mkdir $bckPath/logs
fi

if [ ! -x $bckPath/logs ]
then
  echo -e "$(date --iso-8601='seconds') - [Error] - Unable to access $bckPath/logs... exit\n" > $bckLOG
  exit 1;
fi

bckLOG=$bckPath/logs/mybup_$bckDate.log
ln -s $bckLOG $bckPath/mybup.log

for host in "${DBhost[@]}"
do
   if [ ! -d $bckPath/$host ]
   then
     mkdir $bckPath/$host
   fi

   if [ ! -x $bckPath/$host ]
   then
     echo -e "$(date --iso-8601='seconds') - [Error] - Unable to access $bckPath/$host... exit\n" > $bckLOG
     exit 1;
   fi

   for db in $( mysql -h $host --password=$DBpass -u $DBuser -e 'show databases;' | head -1000 | egrep -Ev 'information_schema|mysql|Database|performance_schema')
   do
     start=$(date '+%s')
     if [ ! -d $bckPath/$host/$db ]
     then
       mkdir $bckPath/$host/$db
       echo -e "$(date --iso-8601='seconds') - [$host] - $db: Found new DB!" >> $bckLOG
     fi
     echo -e "$(date --iso-8601='seconds') - [$host] - $db: executing backup... \c" >> $bckLOG
     bckFile=$bckPath/$host/$db/$host'_'$db'_'$bckDate.sql
     mysqldump -h $host -u $DBuser --password=$DBpass $db > $bckFile
     stop=$(date '+%s')
     bckTime=$((stop-start))
     echo -e "Completed in: $bckTime s" >> $bckLOG
     totTime=$((totTime+bckTime))
     bzip2 $bckFile
   done
   echo -e "$(date --iso-8601='seconds') - [$host] - All databases dumped in $totTime s " >> $bckLOG
done

# Delete old backups
echo -e "\n" >> $bckLOG
echo -e "$(date --iso-8601='seconds') - [Cleaning] - Dumps older than $bckDays days " >> $bckLOG
echo -e "#-----------------------------------------------" >> $bckLOG
find $bckPath/ -type f -name "*.sql.bz2" -mtime +$bckDays -exec rm -fv {} \; &>> $bckLOG
echo -e "#-----------------------------------------------" >> $bckLOG
echo -e "\n" >> $bckLOG
echo -e "$(date --iso-8601='seconds') - [Cleaning] - logs older than $bckDays days " >> $bckLOG
echo -e "#-----------------------------------------------" >> $bckLOG
find $bckPath/ -type f -name "mybup*log" -mtime +$bckDays -exec rm -fv {} \; &>> $bckLOG
echo -e "#-----------------------------------------------" >> $bckLOG
