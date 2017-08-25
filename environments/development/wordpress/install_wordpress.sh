#!/bin/bash

# Set bash to be strict about errors
set -euo pipefail

MYSQL_PASSWORD='password123'
WP_DBNAME=wpdb
WP_USERNAME=wpconnect
WP_PASSWORD=$MYSQL_PASSWORD
SITE_TITLE=CD-WORDPRESS
ADMIN_USERNAME=user1
ADMIN_PASSWORD=$MYSQL_PASSWORD
ADMIN_EMAIL=someone@mailinator.com

# Configure MySQL for Wordpress installation
mysql -u root -p${MYSQL_PASSWORD} <<EOF
  CREATE USER '${WP_USERNAME}'@'localhost' IDENTIFIED BY '${WP_PASSWORD}';
  CREATE DATABASE ${WP_DBNAME};
  GRANT ALL PRIVILEGES ON ${WP_DBNAME}.* TO '${WP_USERNAME}'@'localhost';
  FLUSH PRIVILEGES;
EOF

# Install Apache
yum -y install httpd
yum -y install mod_security
systemctl enable httpd

# Install PHP
yum -y install php
yum -y install php-mysql

# Download and install the latest Wordpress
wget -nv https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
mv wordpress/* /var/www/html/.
chown -R apache:apache /var/www/html/*

# configure SELinux
yum -y install policycoreutils-python
semanage fcontext -a -t httpd_sys_content_t '/var/www/html(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/.htaccess"
# Wordpress almost always involves e-mail communication so enable it
setsebool -P httpd_can_sendmail 1
# If you host the mysql instance on a remote computer, grant permission to connect
#setsebool -P  httpd_can_network_connect_db 1

# Configure Wordpress
cd /var/www/html
sed -e "s/database_name_here/${WP_DBNAME}/" -e "s/username_here/${WP_USERNAME}/" -e "s/password_here/${WP_PASSWORD}/" wp-config-sample.php > wp-config.php
cd -

# Ensure files have correct SELinux permissions
restorecon -R /var/www/html

# Start up web server
systemctl start httpd

# Finish basic Wordpress set up
curl -sS --data @- http://localhost/wp-admin/install.php?step=1 << EOF
language=
EOF

curl -sS --data @- http://localhost/wp-admin/install.php?step=2 << EOF | grep install-success
weblog_title=${SITE_TITLE}&user_name=${ADMIN_USERNAME}&admin_password=${ADMIN_PASSWORD}&pass1-text=${ADMIN_PASSWORD}&admin_password2=${ADMIN_PASSWORD}&pw_weak=on&admin_email=${ADMIN_EMAIL}&Submit=Install+WordPress&language=
EOF
