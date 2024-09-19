#!/bin/bash
# 用户名
username=""
# 密码
passwd=""


sudo_common='sudo '

function create_admin_user() {
  local count=`${sudo_common} egrep ${username} /etc/passwd | wc -l`
  if [ ${count} -eq 0 ]; then
  ${sudo_common}  useradd -r -m -s /bin/bash ${username}
  echo "add user [${username}] success"
  else
    echo "user [${username}] has existed"
  fi
  echo ${username}:${passwd} | chpasswd
  
  if test -z "$(grep "dbf.*NOPASSWD" /etc/sudoers)"; then
    echo "sudo dbf"
    ${sudo_common} chmod u+w /etc/sudoers
    ${sudo_common} sed -i "/^root.*ALL$/a${username}\tALL=(ALL)\tNOPASSWD: ALL" /etc/sudoers
    ${sudo_common} chmod u-w /etc/sudoers;
  else
    echo "user [$username] has in sudo list"
  fi
}

create_admin_user

1. 先执行：
chmod u+w /etc/sudoers
2. 编辑文件
3.chmod u-w /etc/sudoers;

[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql

Type=forking

PIDFile=/run/mysqld/mysqld.pid
PermissionsStartOnly=true
RuntimeDirectory=mysqld
RuntimeDirectoryMode=755

ExecStart=/usr/local/mysql/support-files/mysql.server start
ExecStop=/usr/local/mysql/support-files/mysql.server stop
ExecReload=/usr/local/mysql/support-files/mysql.server restart

Restart=on-failure


[root@localhost ~]# systemctl status mysqld
● mysqld.service - MySQL Server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: activating (start) since Thu 2023-11-16 15:28:19 CST; 1min 2s ago
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html
  Process: 1469396 ExecStart=/usr/local/mysql/support-files/mysql.server start (code=exited, status=0/SUCCESS)
    Tasks: 28
   Memory: 185.9M
   CGroup: /system.slice/mysqld.service
           ├─1469406 /bin/sh /usr/local/mysql/bin/mysqld_safe --datadir=/data/var/lib/mysql --pid-file=/var/lib/mysql/localhost.pid
           └─1470115 /usr/local/mysql/bin/mysqld --basedir=/usr/local/mysql --datadir=/data/var/lib/mysql --plugin-dir=/usr/local/mysql/lib/plugin --log-error=/var/log/mysqld.log --open-files-limit=4096 --pid>

11月 16 15:28:19 localhost.localdomain systemd[1]: mysqld.service: Service RestartSec=100ms expired, scheduling restart.
11月 16 15:28:19 localhost.localdomain systemd[1]: mysqld.service: Scheduled restart job, restart counter is at 11.
11月 16 15:28:19 localhost.localdomain systemd[1]: Stopped MySQL Server.
11月 16 15:28:19 localhost.localdomain systemd[1]: Starting MySQL Server...
11月 16 15:28:20 localhost.localdomain systemd[1]: mysqld.service: Can't open PID file /run/mysqld/mysqld.pid (yet?) after start: No such file or directory
