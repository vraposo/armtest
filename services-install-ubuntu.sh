#!/bin/bash
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
sudo debconf-set-selections <<< 'mariadb-server-10.1 mysql-server/root_password password P2ssw0rd'
sudo debconf-set-selections <<< 'mariadb-server-10.1 mysql-server/root_password_again password P2ssw0rd'

# Modified tcp keepalive according to https://docs.mongodb.org/ecosystem/platforms/windows-azure/
sudo bash -c "sudo echo net.ipv4.tcp_keepalive_time = 120 >> /etc/sysctl.conf"

# Install Mongo DB & Maria DB
sudo apt-get install -y mongodb-org mariadb-server

# Bind to all ip addresses
sudo sed -i -e 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf
sudo service mongod restart
sudo sed -i -e 's/bind-address.*/bind-address=0.0.0.0/' /etc/mysql/my.cnf
sudo service mysql restart