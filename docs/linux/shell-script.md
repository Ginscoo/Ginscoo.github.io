
### 创建用户并添加sudo免密

```shell
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
```