#!/bin/bash
MYSQL_PASS='P2ssw0rd'

# Configure mongodb.list file with the correct location
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# Configure mariadb.list file with the correct location
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
echo "deb http://lon1.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu "$(lsb_release -sc)" main" | sudo tee /etc/apt/sources.list.d/mariadb-server-10.1.list

# Disable THP
sudo echo never > /sys/kernel/mm/transparent_hugepage/enabled
sudo echo never > /sys/kernel/mm/transparent_hugepage/defrag
sudo grep -q -F 'transparent_hugepage=never' /etc/default/grub || echo 'transparent_hugepage=never' >> /etc/default/grub

# Install updates
sudo apt-get -y update

# Configure non-interactive Maria DB installation
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< 'mariadb-server-10.1 mysql-server/root_password password $MYSQL_PASS'
sudo debconf-set-selections <<< 'mariadb-server-10.1 mysql-server/root_password_again password $MYSQL_PASS'

# Modified tcp keepalive according to https://docs.mongodb.org/ecosystem/platforms/windows-azure/
sudo bash -c "sudo echo net.ipv4.tcp_keepalive_time = 120 >> /etc/sysctl.conf"

# Install Mongo DB & Maria DB
sudo apt-get install -y mongodb-org mariadb-server

# Bind to all ip addresses
sudo sed -i -e 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf
sudo service mongod restart
sudo sed -i -e 's/bind-address.*/bind-address=0.0.0.0/' /etc/mysql/my.cnf
sudo service mysql restart

# Setup Maria DB
# mysql -u root -p$MYSQL_PASS <<MYSQL_SCRIPT
# GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.0.%.%' IDENTIFIED BY '$MYSQL_PASS' WITH GRANT OPTION;
# CREATE DATABASE IF NOT EXISTS nossafreguesia;
# CREATE USER 'nfmysqluser'@'10.0.%.%' IDENTIFIED BY 'BSgAHhn3+GrR';
# GRANT ALL PRIVILEGES ON nossafreguesia.* TO 'nfmysqluser'@'10.0.%.%';
# FLUSH PRIVILEGES;
# MYSQL_SCRIPT