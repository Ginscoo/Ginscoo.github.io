## ssh
* 用户名密码登录
    * `ssh root@192.168.10.10`
* 私钥登录
    * `ssh -i auth root@192.168.10.10`

## scp

## ssh-add

## ssh-keygen
* 生成私钥
    * `ssh-key-gen` 按照提示输入默认生成在 `～/.ssh/`下，
    * `ssh-keygen -t rsa -b 2048`
    * `ssh-keygen -t rsa -b 2048 -f ./auth`
* `@ WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED! @`
    * `ssh-keygen -R $ip` 移除无效的IP

## ssh-copy-id
```shell
# 复制公钥到目标服务器
# ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.16.10
ssh-copy-id root@192.168.16.10
```