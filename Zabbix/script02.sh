#!/bin/bash
sudo cat > /etc/sysconfig/network-scripts/ifcfg-eth1 << EOF
DEVICE="eth1"
BOOTPROTO="static"
ONBOOT="yes"
TYPE="Ethernet"
PERSISTENT_DHCLIENT="no"
IPADDR=192.168.1.210
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=1.1.1.1
EOF
sudo /etc/init.d/network restart
sudo echo "zabbix" > /etc/hostname 	
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
sudo systemctl start firewalld && sudo systemctl enable firewalld
###CONFIG APACHE
sudo yum -y install httpd vim
echo -e "ServerSignature Off \nServerTokens Prod" >> /etc/httpd/conf/httpd.conf
sudo sed -i 's/^ServerName.*/ServerName zabbix.labary.local/g' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd
sudo firewall-cmd --add-service={http,https} --permanent && sudo firewall-cmd --reload
###INSTALAR MARIADB
cat <<EOF | sudo tee /etc/yum.repos.d/MariaDB.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.4/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
sudo yum makecache fast
sudo yum -y install MariaDB-server MariaDB-client
sudo systemctl enable --now mariadb
echo "& y y q1w2e3r4t5y6u7i8 q1w2e3r4t5y6u7i8 y y y y" | ./usr/bin/mysql_secure_installation
###CONFIG MARIADB
export zabbix_db_pass="q1w2e3r4t5y6"
mysql -uroot -p <<MYSQL_SCRIPT
    create database zabbix character set utf8 collate utf8_bin;
    grant all privileges on zabbix.* to zabbix@'localhost' identified by '${zabbix_db_pass}';
    FLUSH PRIVILEGES;
MYSQL_SCRIPT
###INSTALARION ZABBIX
sudo yum install -y https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum install zabbix-server-mysql zabbix-agent zabbix-get
sudo yum-config-manager --enable zabbix-frontend
sudo yum -y install centos-release-scl
sudo yum -y install zabbix-web-mysql-scl zabbix-apache-conf-scl
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix --password=q1w2e3r4t5y6u7i8 zabbix
sudo sed -i 's/^DBName=.*/DBName=zabbix/g' /etc/httpd/conf/httpd.conf
sudo sed -i 's/^DBUser=.*/DBUser=zabbix/g' /etc/httpd/conf/httpd.conf
sudo sed -i 's/^DBPassword=.*/DBPassword=q1w2e3r4t5y6u7i8/g' /etc/httpd/conf/httpd.conf
echo "php_value[date.timezone] = America/Fortaleza" >> /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
sudo systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
sudo systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm
sudo firewall-cmd --add-port={10051/tcp,10050/tcp} --permanent
sudo firewall-cmd --reload
sudo systemctl restart httpd

