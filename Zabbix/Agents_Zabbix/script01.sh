#!/bin/bash
sudo cat > /etc/sysconfig/network-scripts/ifcfg-eth1 << EOF
DEVICE="eth1"
BOOTPROTO="static"
ONBOOT="yes"
TYPE="Ethernet"
PERSISTENT_DHCLIENT="no"
IPADDR=192.168.1.211
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=1.1.1.1
EOF
sudo echo "zabbix_agent01" > /etc/hostname 	
sudo nmcli networking off && sudo nmcli networking on
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
sudo systemctl start firewalld && sudo systemctl enable firewalld
sudo yum update -y && sudo yum install -y nfs-common vim expect epel wget htop && sudo yum -y clean all
###CONFIG AGENT
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
sudo yum -y clean all
sudo yum install zabbix-agent2
sudo sed -i 's/^Server=.*/Server=192.168.1.210/g' /etc/httpd/conf/httpd.conf
sudo sed -i 's/^ServerActive=.*/Server=192.168.1.210/g' /etc/httpd/conf/httpd.conf
sudo sed -i 's/^Hostname=.*/Hostname=zabbix_agent01/g' /etc/httpd/conf/httpd.conf
sudo firewall-cmd --add-port=10050/tcp --permanent && sudo firewall-cmd --reload
sudo systemctl enable zabbix-agent2 && sudo systemctl start zabbix-agent2
sudo reboot