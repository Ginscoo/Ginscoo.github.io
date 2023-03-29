
## 常用命令

## 主从服务设置
### master配置
```
# vim my.cnf 

[mysqld]
port=3307
character-set-server = utf8
secure_file_priv=""
max_connections=1000
max_allowed_packet=40M

server-id = 1        # 节点ID，确保唯一

# log config
log-bin = mysql-bin     #开启mysql的binlog日志功能
sync_binlog = 1         #控制数据库的binlog刷到磁盘上去 , 0 不控制，性能最好，1每次事物提交都会刷到日志文件中，性能最差，最安全
binlog_format = mixed   #binlog日志格式，mysql默认采用statement，建议使用mixed
expire_logs_days = 7                           #binlog过期清理时间
max_binlog_size = 100m                    #binlog每个日志文件大小
binlog_cache_size = 4m                        #binlog缓存大小
max_binlog_cache_size= 512m              #最大binlog缓存大
binlog-ignore-db=mysql #不生成日志文件的数据库，多个忽略数据库可以用逗号拼接，或者 复制这句话，写多行

slave-skip-errors
```

### slave配置
```
...
server-id = 2        # 此处唯一与master区分即可
...

```
### 数据同步
master 服务器

    show master status;         // 从服务器配置会用到
salve 服务器

    # 首先关闭从服务器配置
    stop slave;

    # 设置master信息
    change master to 
    master_host='localhost',              
    master_port=3307,
    master_user='root',                   // master有权限的账号，没有则须新建
    master_password='111111',
    master_log_file='mysql-bin.000002',   // 连接master , 执行 show master status 查看
    master_log_pos=154;                   // // 连接master , 执行 show master status 查看

    # 启动从服务器
    start slave;

    # 查看从服务器信息
    show slave status;

### 修改数据库权限
```
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '111111' WITH GRANT OPTION;
    flush privileges;
```
```shell
# 8.0
create user 'ginsco'@'%' identified by 'Admin@123';
# grant all on *.* to 'ginsco@%' with grant option; 
grant all on *.* to 'ginsco'@'%';
flush privileges;

# navicat 报错 'caching_sha2_password' cannot be loaded: dlopen(../Frameworks/caching_sha2_password.so, 2): image n
alter user 'ginsco'@'%' identified with mysql_native_password by 'Admin@123';

```

## 错误修复
### 服务器非正常关闭启动mysql - MySQL. ERROR! The server quit without updating PID file

```Shell
2021-01-12T02:57:06.618034Z 0 [Note] InnoDB: Removed temporary tablespace data file: "ibtmp1"
2021-01-12T02:57:06.618047Z 0 [Note] InnoDB: Creating shared tablespace for temporary tables
2021-01-12T02:57:06.618124Z 0 [Note] InnoDB: Setting file './ibtmp1' size to 12 MB. Physically writing the file full; Please wait ...
2021-01-12T02:57:06.625262Z 0 [Note] InnoDB: File './ibtmp1' size is now 12 MB.
2021-01-12T02:57:06.625863Z 0 [Note] InnoDB: 96 redo rollback segment(s) found. 96 redo rollback segment(s) are active.
2021-01-12T02:57:06.625872Z 0 [Note] InnoDB: 32 non-redo rollback segment(s) are active.
2021-01-12T02:57:06.626288Z 0 [Note] InnoDB: Waiting for purge to start
2021-01-12 10:57:06 0x7f44f27fc700  InnoDB: Assertion failure in thread 139934102963968 in file fut0lst.ic line 93
InnoDB: Failing assertion: addr.page == FIL_NULL || addr.boffset >= FIL_PAGE_DATA
InnoDB: We intentionally generate a memory trap.
InnoDB: Submit a detailed bug report to http://bugs.mysql.com.
InnoDB: If you get repeated assertion failures or crashes, even
InnoDB: immediately after the mysqld startup, there may be
InnoDB: corruption in the InnoDB tablespace. Please refer to
InnoDB: http://dev.mysql.com/doc/refman/5.7/en/forcing-innodb-recovery.html
InnoDB: about forcing recovery.
02:57:06 UTC - mysqld got signal 6 ;
This could be because you hit a bug. It is also possible that this binary
or one of the libraries it was linked against is corrupt, improperly built,
or misconfigured. This error can also be caused by malfunctioning hardware.
Attempting to collect some information that could help diagnose the problem.
As this is a crash and something is definitely wrong, the information
collection process might fail.

key_buffer_size=8388608
read_buffer_size=131072
max_used_connections=0
max_threads=1000
thread_count=0
connection_count=0
It is possible that mysqld could use up to 
key_buffer_size + (read_buffer_size + sort_buffer_size)*max_threads = 405574 K  bytes of memory
Hope that's ok; if not, decrease some variables in the equation.

Thread pointer: 0x7f44ec000900
Attempting backtrace. You can use the following information to find out
where mysqld died. If you see no messages after this, something went
terribly wrong...
stack_bottom = 7f44f27fbdb8 thread_stack 0x40000
/usr/local/ssdsm_/mysql/bin/mysqld(my_print_stacktrace+0x35)[0xf8e995]
/usr/local/ssdsm_/mysql/bin/mysqld(handle_fatal_signal+0x4b9)[0x802e49]
/lib64/libpthread.so.0(+0xf630)[0x7f4513ccd630]
/lib64/libc.so.6(gsignal+0x37)[0x7f45126b5387]
/lib64/libc.so.6(abort+0x148)[0x7f45126b6a78]
/usr/local/ssdsm_/mysql/bin/mysqld(_Z18ut_print_timestampP8_IO_FILE+0x0)[0x7f1e5e]
/usr/local/ssdsm_/mysql/bin/mysqld[0x125c848]
/usr/local/ssdsm_/mysql/bin/mysqld[0x125cb25]
/usr/local/ssdsm_/mysql/bin/mysqld(_Z9trx_purgemmb+0x60d)[0x125f2ad]
/usr/local/ssdsm_/mysql/bin/mysqld(srv_purge_coordinator_thread+0x9b7)[0x1241eb7]
/lib64/libpthread.so.0(+0x7ea5)[0x7f4513cc5ea5]
/lib64/libc.so.6(clone+0x6d)[0x7f451277d96d]
```

查看mysql日志，如果出现

    InnoDB: http://dev.mysql.com/doc/refman/5.7/en/forcing-innodb-recovery.html
    InnoDB: about forcing recovery.
则可能是innodb表空间损，可使用 **innodb_force_recovery** 尝试修复或者导出数据修复
**innodb_force_recovery参数说明：**
* MySQL数据库当innodb表空间损坏时（如ibdata1文件损坏），尝试启动Mysql服务失败。这个时候可以使用innodb_force_recovery参数进行强制启动
* innodb_force_recovery影响整个InnoDB存储引擎的恢复状况，默认值为0，表示当需要恢复时执行所有的恢复操作！
* 当不能进行有效的恢复操作时，Mysql有可能无法启动，并记录下错误日志。
 
* innodb_force_recovery可以设置为1-6，大的数字包含前面所有数字的影响。
* 当该参数的数值设置大于0后，可以对表进行select，create，drop操作，但insert，update或者delete这类操作是不允许的。
    * innodb_force_recovery=0   表示当需要恢复时执行所有的恢复操作；
    * innodb_force_recovery=1   表示忽略检查到的corrupt页；
    * innodb_force_recovery=2   表示阻止主线程的运行，如主线程需要执行full purge操作，会导致crash；
    * innodb_force_recovery=3   表示不执行事务回滚操作；
    * innodb_force_recovery=4   表示不执行插入缓冲的合并操作；
    * innodb_force_recovery=5   表示不查看重做日志，InnoDB存储引擎会将未提交的事务视为已提交；
    * innodb_force_recovery=6   表示不执行前滚的操作，强制重启！
 * 一种修复步骤

```
# vim my.cnf
innodb_force_recovery=6

#启动mysql服务
service mysqld start
# 备份数据 navicat 或者myqldump
# 删除数据或者重装mysql
```