# mybup
MySQL / MariaDB backup scripts

This script can dump all databases on a single machine or from several hosts.

Before executing the script you should create a user with read-only privilege on the databases that you want to backup.

If you want to backup the databases locally on the same mysql server follow these steps:
* Connect to your DB Server
* CREATE USER 'USERNAME'@'localhost' IDENTIFIED BY 'PASSWORD'; (replace USERNAME and PASSWORD with your values)
* GRANT SELECT, LOCK TABLES, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'USERNAME'@'localhost';

If you need to backup the databases from a remote machine follow these steps:
* Connect to your DB Server
* CREATE USER 'USERNAME'@'xxx.xxx.xxx.xxx' IDENTIFIED BY 'PASSWORD'; (xxx.xxx.xxx.xxx must be the IP address used by the backup box to connect to, replace USERNAME and PASSWORD with your values)
* GRANT SELECT, LOCK TABLES, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'USERNAME'@'xxx.xxx.xxx.xxx';

Repeat for each server do you need to backup

For example on my setup all servers are reachable using a VPN and I run mybup.sh on a backup machine:

             |--- 10.1.1.20  DB server 1
             |--- 10.1.1.21  DB server 2
10.1.1.1 ----|--- 10.1.1.22  DB server 3
             |--- 10.1.1.23  DB server 4
             |--- 10.1.1.24  DB server 5
