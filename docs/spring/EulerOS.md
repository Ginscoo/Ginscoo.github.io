## EulerOS安装CentOS rpm包依赖冲突问题

先卸载EulerOS上的rpm
`rpm -e --nodeps xxx.rpm`
`rpm -ivh xxx.rpm`
`rpm -ivh xxx.rpm`
大概率centOS 版本和EulerOS可以共存。

### 下载依赖包
yum install readline.x86_64 --downloadonly --downloaddir=/home/extra-rpm
yum reinstall readline.x86_64 --downloadonly --downloaddir=/home/extra-rpm

```Shell
# 解决openssl安装缺少依赖的问题
rpm -ivh make-3.82-24.el7.x86_64.rpm

# 解决unix-odbc缺少依赖的问题
# 先降级再安装可以共存
rpm -e --nodeps readline-8.0-3.h1.eulerosv2r10.x86_64
rpm -ivh readline-6.2-11.el7.x86_64.rpm 
rpm -ivh readline-8.0-3.h1.eulerosv2r10.x86_64.rpm 

# 解决`rng-tools-6.3.1-5.el7.x86_64.rpm`依赖问题
# 先降级再安装可以共存
rpm -e --nodeps libgcrypt-1.8.6-2.h7.eulerosv2r10.x86_64
rpm -ivh libgcrypt-1.5.3-14.el7.x86_64.rpm
rpm -ivh libgcrypt-1.8.6-2.h7.eulerosv2r10.x86_64.rpm


# 未解决gdb依赖问题，线上问题调试工具，影响不大
# warning: rpm/gdb-7.6.1-119.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
# error: Failed dependencies:
#         libpython2.7.so.1.0()(64bit) is needed by gdb-7.6.1-119.el7.x86_64
# start installing, numactl-libs-2.0.12-5.el7.x86_64.rpm
```
