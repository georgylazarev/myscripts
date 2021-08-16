#!/bin/bash

se=`sestatus | awk ' NR==1{print $3} '`

if [[ $se = 'enabled' ]]
then
echo "Disable selinux then come back";
exit;
fi

dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf -y module reset php:7.2
dnf -y module enable php:remi-7.4
dnf -y update

dnf -y install git nano wget curl mc httpd mysql mysql-server php php-cli php-mysqlnd php-json php-gd php-ldap php-odbc php-pdo php-opcache php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap php-zip

firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

systemctl enable httpd
systemctl start httpd
systemctl enable mysqld
systemctl start mysqld

mysql_secure_installation
