#!/bin/bash

# Exit the script on any errors
set -euo pipefail

# Download MySQL for CentOS 7
wget -nv https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm

# Install MySQL
yum -y localinstall mysql57-community-release-el7-11.noarch.rpm
yum -y install mysql-community-server

# Set MySQL root password
systemctl start mysqld
sleep 30 # wait for initialization
ROOT_PASSWORD=`awk '/temporary password/{print $NF}' /var/log/mysqld.log`
mysql -u root -p${ROOT_PASSWORD} --connect-expired-password -e 'SET GLOBAL validate_password_policy = 0; ALTER USER "root"@"localhost" IDENTIFIED BY "password123"; FLUSH PRIVILEGES'
