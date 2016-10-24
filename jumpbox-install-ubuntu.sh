#!/bin/bash
# Configure mongodb.list file with the correct location
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# Configure mariadb.list file with the correct location
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
echo "deb http://lon1.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu "$(lsb_release -sc)" main" | sudo tee /etc/apt/sources.list.d/mariadb-server-10.1.list

# Install updates
sudo apt-get -y update

# Install Mongo DB & Maria DB
sudo apt-get install -y mongodb-clients mariadb-client