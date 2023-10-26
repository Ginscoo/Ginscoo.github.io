#!/bin/bash
#查看mariadb mysql是否已安装存在则删除
rpm -e --nodeps $(rpm -qa | grep mariadb)
rpm -e --nodeps $(rpm -qa | grep mysql)
rpm -e --nodeps $(rpm -qa | grep MySQL)
#安装顺序
rpm -ivh --force rpm/mysql-community-common-*.rpm
rpm -ivh --force rpm/mysql-community-libs-*.rpm
rpm -ivh --force rpm/mysql-community-client-*.rpm
rpm -ivh --nodeps rpm/mysql-community-server-*.rpm
rpm -ivh --nodeps rpm/mysql-community-devel-*.rpm
#启动mysql
systemctl start mysqld
systemctl enable mysqld 

sleep 5
defaultmysqlpwd=`grep 'A temporary password' /var/log/mysqld.log | awk -F"root@localhost: " '{ print $2}' `
if [ ! ${defaultmysqlpwd} ];then
    defaultmysqlpwd="Reduck@2023"
fi
echo ${defaultmysqlpwd}
/usr/bin/mysql -uroot -p${defaultmysqlpwd} --connect-expired-password -e "set global validate_password_policy=1;
SET PASSWORD = PASSWORD('Reduck@2023');"


systemctl restart mysqld


/usr/bin/mysql -uroot -p'u)<ZotBq-7Kf' --connect-expired-password -e "set global validate_password_policy=1;
SET PASSWORD = PASSWORD('Reduck@2023');"