# mybup
MySQL / MariaDB backup scripts

This script can dump all databases from a single sever or a pool of servers.

Before executing the script you should create a user with read-only privilege on the databases that you want to backup.

All databases will be stored in the folder defined by **$bckPath** with this structure:
```
DataBase/
├── host1
│   ├── database1
│   ├── database2
│   ├── database3
│   ├── database4
│   └── database5
├── host2
│   ├── database1
│   ├── database2
│   └── database3
├── host3
│   ├── database1
│   ├── database2
│   ├── database3
│   └── database4
├── host4
│   ├── database1
│   ├── database2
└── logs
```

## How to setup mybup.sh
There are 5 parameters that you have to set:
```
DBhost=( HOST1 HOST2 HOST3 HOST4 )
DBuser='USERNAME'
DBpass='PASSWORD'
bckPath='/YOUR_BACKUP_PATH/DataBase'
bckDays='30' #Delete backup older then 'bckDays' days
```

### Backup DBs locally
If you want to backup the databases locally on the same mysql server, connect to your DB server and follow these steps:
```
 CREATE USER 'USERNAME'@'localhost' IDENTIFIED BY 'PASSWORD'; (replace USERNAME and PASSWORD with your values)
 GRANT SELECT, LOCK TABLES, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'USERNAME'@'localhost';
```
Inside mybup.sh set:
```
DBhost=( localhost )
```

### Backup DBs on a remote machine
If you need to backup the databases from a remote machine, you have to create a backup-user on each DB server following these steps:
```
 CREATE USER 'USERNAME'@'xxx.xxx.xxx.xxx' IDENTIFIED BY 'PASSWORD'; (xxx.xxx.xxx.xxx must be the IP address used by the backup box to connect to, replace USERNAME and PASSWORD with your values)
 GRANT SELECT, LOCK TABLES, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'USERNAME'@'xxx.xxx.xxx.xxx';
```
Inside mybup.sh set:
```
DBhost=( HOST1 HOST2 HOST3 HOST4 )
```

### Output Example
Logs are stored in **$bckPath/logs** and files older than **$bckDays** will be deleted.
When you start **mybup** automatically a new symlink **$bckPath/mybup.log** will be created pointing to the last log file into the defined folder: **$bckPath/logs**.
To check last backup use this command:

```
tail -f $bckPath/mybup.log
```

```
2017-05-30T20:04:44+0200                       [test.cipenso.io] Dumping all DB
-------------------------------------------------------------------------------
DB name                         Time    Size      ZIP Size        Dump     ZIP
-------------------------------------------------------------------------------
database1                        47s    3,9M          215K          OK      OK
database2                         9s     17K          2,5K          OK      OK
                            [test.cipenso.io] - All databases dumped in 56 s
```

## Example: backups DBs from 5 servers on a remote machine

For example on my setup all servers are reachable using a VPN and I run mybup.sh on a backup machine:

```
               |--- 10.1.1.20  DB server 1
 Backup Host   |--- 10.1.1.21  DB server 2
 10.1.1.1 -----|--- 10.1.1.22  DB server 3
               |--- 10.1.1.23  DB server 4
               |--- 10.1.1.24  DB server 5
```
