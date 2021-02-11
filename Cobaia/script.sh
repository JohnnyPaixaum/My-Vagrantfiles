#!/bin/bash
sudo hostnamectl set-hostname cobaia && \						
sudo apt update && sudo apt upgrade && sudo apt install epel nfs-kernel-server htop glances && \
sudo systemctl enable nfs-kernel-server && sudo systemctl restart nfs-kernel-server && \
sudo sudo ufw allow from 192.168.1.0/24 to any port nfs	
###CONFIG NFS
sudo adduser --no-create-home -s /sbin/nologin cobaia
sudo groupadd nfs_comp
sudo usermod -aG nfs_comp cobaia
sudo mkdir -p /var/nfs/general
sudo chown cobaia:nfs_comp /var/nfs/general
sudo chmod 0770 /var/nfs/general
sudo echo "/var/nfs/general 192.168.1.211(rw,sync,no_subtree_check)" >> /etc/exports
sudo expect -c "spawn passwd teste \
expect "Enter password for user root:" \
send "$password\r" \
expect eof"