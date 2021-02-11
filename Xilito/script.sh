#!/bin/bash
sudo hostnamectl set-hostname xilito && \						
sudo apt update && sudo apt upgrade && sudo apt install epel nfs-kernel-server vim expect htop glances && \
sudo systemctl enable nfs-kernel-server && sudo systemctl restart nfs-kernel-server && \
sudo sudo ufw allow from 192.168.1.0/24 to any port nfs	
###CONFIG NFS
sudo useradd --no-create-home -s /sbin/nologin xilito
sudo groupadd nfs_comp
sudo usermod -aG nfs_comp xilito
sudo mkdir -p /var/nfs/general
sudo chown xilito:nfs_comp /var/nfs/general
sudo chmod 0770 /var/nfs/general
PASSWD="q1w2e3r4"
sudo expect -c "spawn passwd teste \
expect "Enter password for user root:" \
send "$PASSWD\r" \
expect eof"
sudo echo "/var/nfs/general 192.168.1.210(rw,sync,no_subtree_check)" >> /etc/exports
sudo exportfs -a