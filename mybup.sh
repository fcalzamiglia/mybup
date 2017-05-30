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

   totTime=0

   printf "%24s%55s\n" "$(date --iso-8601='seconds')" "[$host] Dumping all DB"        >> $bckLOG
   echo -e '-------------------------------------------------------------------------------' >> $bckLOG
   echo -e 'DB name                         Time    Size      ZIP Size        Dump     ZIP ' >> $bckLOG
   echo -e '-------------------------------------------------------------------------------' >> $bckLOG

   for db in $( mysql -h $host --password=$DBpass -u $DBuser -e 'show databases;' | head -1000 | egrep -Ev 'information_schema|mysql|Database|performance_schema')
   do
     start=$(date '+%s')

     if [ ! -d $bckPath/$host/$db ]
     then
       mkdir $bckPath/$host/$db
       echo -e "$db: Found new DB!" >> $bckLOG
     fi

     bckFile=$bckPath/$host/$db/$host'_'$db'_'$bckDate.sql
     mysqldump -h $host -u $DBuser --password=$DBpass $db > $bckFile

     if [ $? -eq 0 ]; then dumpErr='OK'; else dumpErr='ERR'; fi

     stop=$(date '+%s')
     bckTime=$((stop-start))
     dumpSize=$(ls -lh $bckFile | awk '{print $5}')
     bzip2 $bckFile

     if [ $? -eq 0 ]; then bzipErr='OK'; else bzipErr='ERR'; fi

     dumpSizeZip=$(ls -lh $bckFile'.bz2' | awk '{print $5}')

     printf "%-25s %9ss %7s %13s %11s %7s\n" $db $bckTime $dumpSize $dumpSizeZip $dumpErr $bzipErr >> $bckLOG
     totTime=$((totTime+bckTime))

   done
   printf "%80s\n" "[$host] - All databases dumped in $totTime s " >> $bckLOG
   echo -e "\n\n" >> $bckLOG
done

# Delete old backups
echo -e "\n" >> $bckLOG
printf "%24s%55s\n" "$(date --iso-8601='seconds')" "[Cleaning] - Dumps older than $bckDays days" >> $bckLOG
echo -e "#-----------------------------------------------" >> $bckLOG
find $bckPath/ -type f -name "*.sql.bz2" -mtime +$bckDays -exec rm -fv {} \; &>> $bckLOG
echo -e "#-----------------------------------------------" >> $bckLOG
echo -e "\n" >> $bckLOG
printf "%24s%55s\n" "$(date --iso-8601='seconds')" "[Cleaning] - Logs older than $bckDays days" >> $bckLOG
echo -e "#-----------------------------------------------" >> $bckLOG
find $bckPath/ -type f -name "mybup*log" -mtime +$bckDays -exec rm -fv {} \; &>> $bckLOG
echo -e "#-----------------------------------------------" >> $bckLOG



-------------------------------------------------------------------------------
DB name                       Time      Size      ZIP Size        Dump     ZIP
c2supporto                     37s       11M      2,1M              OK      OK
