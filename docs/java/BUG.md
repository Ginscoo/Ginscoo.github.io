### 0.0.1. Process#waitFor() 阻塞
#### 0.0.1.1. 问题
某客户现场，java调用python脚本一直阻塞.重启后就好。

#### 0.0.1.2. 问题排查
排查日志：重启后一段时间调用就好，随后某一次又会卡住，后续的调用也会一直卡住。

#### 0.0.1.3. 问题原因
调用时未及时读取输入流导致缓存区满了

#### 0.0.1.4. 解决方案
* `Process#getInputStream()`及时读取缓冲区数据
* `Process#destroy`结束时手动调用销毁方法，销毁进程

### 0.0.2. Zip4J压缩后解压失败
#### 0.0.2.1. 问题
某次项目功能移植，利用zip4J压缩报表，解压时提示文件已损坏

#### 0.0.2.2. 问题排查
通过日志排查，未发现问题。借助`ChatGPT`通过手写测试用例，模拟压缩过程。

#### 0.0.2.3. 问题原因
`ZipOutputStreamclose()`之前未调用`ZipOutputStream#closeEntry()`导致
原项目用的`2.10+`版本,`close()`时会检查是否`closeEntry()`,目标项目用的`2.5+`版本，需要手动调用

#### 0.0.2.4. 解决方案
* 升级`zip4J`版本到`2.10+`
* `close()`之前`closeEntry()`,这种方式在一些流式压缩场景不适用，如PDF、Word、Http响应流。高版本设计更合理些

### 0.0.3. SpringBean注入为空的问题
#### 0.0.3.1. 问题
有个`Bean` `A` 和`Bean` `B`,其中`B`是`A`的内部类，
当`A`调用`B`中的`a()`,`b()`,`c()`方法时，`a()`,和`b()`中的B注入的Bean都有值，当调用c方法时，对应的bean为空,导致`NPE`

#### 0.0.3.2. 问题排查
通过多次怀疑人生代码修改，最终发现`c()`方法为private

#### 0.0.3.3. 问题原因
`B`作为`A`的内部类未实现接口，B中的方法是通过Cglib进行代理的。
Cglib代理存在如下限制
* final 方法：final 方法是无法被子类覆盖的，因此CGlib无法对其进行代理。
* static 方法：static 方法属于类级别的方法，而不是实例级别的方法，因此CGlib无法对其进行代理。
* private 方法：private 方法是私有方法，只能在类内部访问，因此CGlib无法直接访问和代理这些方法。
* 原生方法（Native methods）：原生方法是通过本地代码实现的方法，无法通过字节码生成的方式进行代理。

#### 0.0.3.4. 解决方案
修改方法为public

### 0.0.4. spring-boot-web x-wwww-form-urlencoded请求参数中文乱码
#### 0.0.4.1. 问题
在写自动化初始环境，某接口使用`x-wwww-form-urlencoded`请求，前端请求正常，后端通过`okhttp3`请求请求参数乱码

#### 0.0.4.2. 问题排查
排查请求头：
* 前端请求头`content-type`为`application/x-wwww-form-urlencoded;charset=utf-8`
* 后端请求头`content-type`为`application/x-wwww-form-urlencoded`
其余一致。

初步怀疑是请求头问题 ，查询`chatGPT`,`application/x-wwww-form-urlencoded`不指定编码，则默认为`UTF-8`。

此时按照目标产品版本写个`demo`表单请求接口，测试结果可正常解码，从而可以判断默认情况下无论是否加`charset=utf-8`，后端都应按照`utf-8`处理。

通过有问题环境和demo环境debug分析，发现如果不指定编码，则默认由`CharacterEncodingFilter`过滤器统一处理编码。而有问题环境自定义一个`Filter`用于处理请求头参数，该拦截器优先级设置为最高。该拦截器会在`CharacterEncodingFilter`之前执行，执行的时候会解析参数，由于`CharacterEncodingFilter`未执行，此时请求头又未设置编码，导致会按照默认的`ISO-8859-1`编码解析，从而导致乱码

``

#### 0.0.4.3. 问题原因
* 自定义过滤器优先级过高，在编码过滤器之前执行导致未正确设置编码类型。
* 自定义过滤器会解析参数，导致在未设置编码的情况下就开始了参数解析

#### 0.0.4.4. 解决方案
* 如果要解析参数一定要在`CharacterEncodingFilter`之后执行防止乱码
* 将自定义过滤器优先级降低，保障后执行

### 0.0.5. hibernate执行报错：SQL Error: 1785, SQLState: HY000 
#### 0.0.5.1. 问题
某线上环境通过API下发脱敏策略，添加脱敏规则时，添加脱敏规则失败,日志如下

```LOG
2023-11-07 16:11:28.893 [pool-133-thread-1] WARN  org.hibernate.engine.jdbc.spi.SqlExceptionHelper - SQL Error: 1785, SQLState: HY000 
2023-11-07 16:11:28.893 [pool-133-thread-1] ERROR org.hibernate.engine.jdbc.spi.SqlExceptionHelper - Statement violates GTID consistency: Updates to non-transactional tables can only be done in either autocommitted statements or single-statement transactions, and never in the same statement as updates to transactional tables. 
2023-11-07 16:11:28.893 [pool-133-thread-1] INFO  cn.secsmart.admin.config.aspect.policy.SyncPolicyAfterTransactionAspect - execution(void cn.secsmart.admin.rule.service.impl.RuleServiceImpl.apiAddMaskRule(MaskRuleDTO)) 
2023-11-07 16:11:28.894 [pool-133-thread-1] ERROR org.hibernate.AssertionFailure - HHH000099: an assertion failure occurred (this may indicate a bug in Hibernate, but is more likely due to unsafe use of the session): org.hibernate.AssertionFailure: null id in cn.secsmart.admin.resource.entity.DbConfigJson entry (don't flush the Session after an exception occurs) 
2023-11-07 16:11:28.895 [pool-133-thread-1] INFO  cn.secsmart.admin.config.aspect.policy.SyncPolicyAfterTransactionAspect - execution(void cn.secsmart.admin.rule.service.impl.RuleServiceImpl.apiAddMaskRule(MaskRuleDTO)) 
2023-11-07 16:11:28.895 [pool-133-thread-1] ERROR org.hibernate.AssertionFailure - HHH000099: an assertion failure occurred (this may indicate a bug in Hibernate, but is more likely due to unsafe use of the session): org.hibernate.AssertionFailure: null id in cn.secsmart.admin.resource.entity.DbConfigJson entry (don't flush the Session after an exception occurs) 
2023-11-07 16:11:28.895 [pool-133-thread-1] INFO  cn.secsmart.admin.config.aspect.policy.SyncPolicyAfterTransactionAspect - execution(void cn.secsmart.admin.rule.service.impl.RuleServiceImpl.apiAddMaskRule(MaskRuleDTO)) 
```

#### 0.0.5.2. 问题排查
开始注意力在
```LOG 
ERROR org.hibernate.AssertionFailure - HHH000099: an assertion failure occurred (this may indicate a bug in Hibernate, but is more likely due to unsafe use of the session): org.hibernate.AssertionFailure: null id in cn.secsmart.admin.resource.entity.DbConfigJson entry (don't flush the Session after an exception occurs) 
2023-11-07 16:11:28.895 [pool-133-thread-1] INFO  cn.secsmart.admin.config.aspect.policy.SyncPolicyAfterTransactionAspect - execution(void cn.secsmart.admin.rule.service.impl.RuleServiceImpl.apiAddMaskRule(MaskRuleDTO)) 
```
该日志重复打印了几千遍。一通google后无果。
排查代码也都正常，不明白为何ID为空。
后来注意到
```LOG
2023-11-07 16:11:28.893 [pool-133-thread-1] WARN  org.hibernate.engine.jdbc.spi.SqlExceptionHelper - SQL Error: 1785, SQLState: HY000 
2023-11-07 16:11:28.893 [pool-133-thread-1] ERROR org.hibernate.engine.jdbc.spi.SqlExceptionHelper - Statement violates GTID consistency: Updates to non-transactional tables can only be done in either autocommitted statements or single-statement transactions, and never in the same statement as updates to transactional tables. 
```
看到有个解释，基本只有在事务中操作同时操作InnoDB表和MyiSAM表是会出现这种情况。

仔细查看：` Updates to non-transactional tables can only be done in either autocommitted statements or single-statement transactions, and never in the same statement as updates to transactional tables. `  

翻译就是：`不能在同一个更新语句中更新非事务表和事务表`，因为MyiSAM 不支持事务。

遂查看表结构果然发现有一些表是InnoDB,一些表是MyiSAM

#### 0.0.5.3. 问题原因
mysql库中InnoDB和MyiSAM混用，在同一个事务或者语句中同时进行更InnoDB表和MyiSAM表导致
参考[https://dadabik.com/forum/index.php?threads/error-1785-statement-violates-gtid-consistency.22541/](https://dadabik.com/forum/index.php?threads/error-1785-statement-violates-gtid-consistency.22541/)

#### 0.0.5.4. 解决方案
将所有表都改为InnoDB，正常业务开发都应该使用InnoDB，MyiSAM不推荐使用

### 0.0.6. OJDBC oracle获取连接超时或者缓慢

#### 0.0.6.1. 解决方案
*  查看`/dev/random`文件是否随机数不足
    * 执行`head -n 1 /dev/random`如果一直阻塞，可能是随机数不足，可增加启动参数 `-Djava.security.egd=/dev/urandom`
* 查看 `/ect/reslov.conf`配置的DNS是否有效
    * 如果有配置DNS 执行`nslookup -port=53 127.0.0.1 $DNS_IP`,如果很慢或者不通，删除无效的DNS

### 0.0.7. 每次请求JSESSIONID都会变化

#### 0.0.7.1. 问题
每次请求时,请求头 Cookie: JSESSIONID=AAA
每次响应时，响应头 Set-Cookie: JSESSIONID=BBB
导致每次请求都会用一个新的session

#### 0.0.7.2. 问题原因
配置了`server.servlet.session.cookie.name=SESSIONID`，由于`JSESSIONID`与`SESSIONID`不匹配
服务端不认为是一个有效的`SESSION `会重新生成一个`SESSIONID`

#### 0.0.7.3. 解决方案
不配置 `server.servlet.session.cookie.name=SESSIONID`，默认会使用`JSESSIONID`

#### 0.0.7.4. 疑问 
为什么返回的 Set-Cookie里还是`JSESSIONID` 呢

### 0.0.8. Clickhouse百亿数据分页查询很慢

#### 0.0.8.1. 问题
clickhouse百亿数据 ，查询一段时间的数据，查询前15条数据 ，且查询全量字段（40+）耗时数十秒

#### 0.0.8.2. 分析
查询所有列需要数十秒，仅查询ID在一秒以内。初步猜想百亿数据查询全量字段并按照条件查询，可能不需要的数据列也会加载。

#### 0.0.8.3. 解决方案
利用子查询，先根据条件检索出ID，在根据ID检索具体内容。
`select a,b,c... from  t1 where id in (select id from t1 where ....)`

### 0.0.9. openJDK加载字体空指针 - FontConfiguration.getVersion(...)
#### 0.0.9.1. 问题
将oracleJDK换成openJDK, java生成报表模块报错
```Java
java.lang.NullPointerException
        at sun.awt.FontConfiguration.getVersion(FontConfiguration.java:1264)
        at sun.awt.FontConfiguration.readFontConfigFile(FontConfiguration.java:219)
        at sun.awt.FontConfiguration.init(FontConfiguration.java:107)
```

#### 0.0.9.2. 原因
* openJDK-headless缺少字体管理，装openJDK非headless版本
[https://stackoverflow.com/questions/30626136/cannot-load-font-in-jre-8](https://stackoverflow.com/questions/30626136/cannot-load-font-in-jre-8)
```
It turns out that this is a problem with the openjdk-8-jre-headless installation. This is the installation in the Docker image for java 8 JRE. I simply install openjdk-8-jre (without headless) and the problem goes away.

If you look at the error log, the loading of the font require awt X11, which is missing from headless version of JRE.
```
* 系统缺少字体管理器，安装一下字体管理器
```shell
yum install fontconfig
fc-cache --force
```

#### 0.0.9.3. 解决
通过`rpm  -qa | grep font`发现部署机器缺少无字体管理器，找一台有字体管理机器正常 。
由于环境验证，这里倾向第二种解决此问题。第一种未找到tar.gz安装包，未验证


### 0.0.10. Server shutdown in progress Mysql

#### 0.0.10.1. 问题
环境：arm+kylin10
配置mysql主主同步后，重启mysql和服务报错，服务器报
```
java.sql.sqlNonTransientConnectionException: Server shutdown in progress
```
#### 0.0.10.2. 分析
查看mysql状态`systemctl status mysqld`
```shell
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
```
状态为`Active: activating (start) `正常应该是`Active: activating (running) `
日志有异常`Can't open PID file /run/mysqld/mysqld.pid (yet?) after start: No such file or directory`
怀疑是PID问题，查看service内容
```service
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
```
`PIDFile=/run/mysqld/mysqld.pid`与实际不一致`--pid-file=/var/lib/mysql/localhost.pid`
尝试删除`PIDFile=/run/mysqld/mysqld.pid`，可以正常启动

#### 0.0.10.3. 解决方案 

* 保持`mysqld.service`内`PIDFile=/run/mysqld/mysqld.pid`和实际的PID 路径一致 
* 该问题仅在主主同步模式下存在，单机正常 
* 该问题后通过`flyway`重新初始化数据库，发现存在重复主键，原因是主主同步会存在设置步长问题。sql内有的通过自增主键，有的是指定主键，设置步长后存在自增后的ID与部分指定ID重复

### 0.0.11. kylin环境Java被OOM killer
#### 0.0.11.1. 问题
某个java进程连续跑自动化失败

#### 0.0.11.2. 分析
查看服务状态被kill -9，一般是系统内存不足，被oom-killer
查看oom-killer日志
```log
[root@localhost ~]# cat /var/log/messages | grep oom-killer
Nov 13 12:36:15 localhost kernel: [1042091.386259] java invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
Nov 14 16:53:46 localhost kernel: [1143940.898606] ukui-greeter invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
Nov 15 03:24:04 localhost kernel: [1181757.487723] nginx invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
Nov 16 03:33:14 localhost kernel: [1268706.628740] sshd invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
Nov 17 03:27:36 localhost kernel: [1354767.093009] nginx invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
```
发现确实如此
以前遇到过kylin环境有个audit服务会占用内存 ，查看audit服务状态为启动。

#### 0.0.11.3. 解决方案 
禁用auditd 
`systemctl stop auditd`
`systemctl disable auditd`

### 0.0.12. SQL-server连接失败 - javax.net.ssl.SSLHandshakeException: The server selected protocol version TLS10 is not accepted by client preferences [TLS12] 

#### 0.0.12.1. 问题
替换oracleJDK8 为openJDK8后，SQL-server连接失败

#### 0.0.12.2. 问题分析

查看日志

```log
        at java.lang.Thread.run(Thread.java:750)
Caused by: com.microsoft.sqlserver.jdbc.SQLServerException: The driver could not establish a secure connection to SQL Server by using Secure Sockets Layer (SSL) encryption. Error: "The server selected protocol version TLS10 is not accepted by client preferences [TLS12]". ClientConnectionId:181acafd-73a8-444b-ad31-3239a0917c71
        at com.microsoft.sqlserver.jdbc.SQLServerConnection.terminate(SQLServerConnection.java:2646)
        at com.microsoft.sqlserver.jdbc.TDSChannel.enableSSL(IOBuffer.java:1816)
        at com.microsoft.sqlserver.jdbc.SQLServerConnection.connectHelper(SQLServerConnection.java:2233)
        at com.microsoft.sqlserver.jdbc.SQLServerConnection.login(SQLServerConnection.java:1898)
        at com.microsoft.sqlserver.jdbc.SQLServerConnection.connectInternal(SQLServerConnection.java:1739)
        at com.microsoft.sqlserver.jdbc.SQLServerConnection.connect(SQLServerConnection.java:1063)
        at com.microsoft.sqlserver.jdbc.SQLServerDriver.connect(SQLServerDriver.java:572)
        at java.sql.DriverManager.getConnection(DriverManager.java:664)
        at java.sql.DriverManager.getConnection(DriverManager.java:247)
        at cn.everfort.core.DatabaseConnectionUtils.testConnect(DatabaseConnectionUtils.java:103)
        ... 103 common frames omitted
Caused by: javax.net.ssl.SSLHandshakeException: The server selected protocol version TLS10 is not accepted by client preferences [TLS12]
        at sun.security.ssl.Alert.createSSLException(Alert.java:131)
        at sun.security.ssl.Alert.createSSLException(Alert.java:117)
        at sun.security.ssl.TransportContext.fatal(TransportContext.java:311)
        at sun.security.ssl.TransportContext.fatal(TransportContext.java:267)
        at sun.security.ssl.TransportContext.fatal(TransportContext.java:258)
        at sun.security.ssl.ServerHello$ServerHelloConsumer.onServerHello(ServerHello.java:943)
        at sun.security.ssl.ServerHello$ServerHelloConsumer.consume(ServerHello.java:869)
        at sun.security.ssl.SSLHandshake.consume(SSLHandshake.java:377)
        at sun.security.ssl.HandshakeContext.dispatch(HandshakeContext.java:444)
        at sun.security.ssl.HandshakeContext.dispatch(HandshakeContext.java:422)
        at sun.security.ssl.TransportContext.dispatch(TransportContext.java:182)
        at sun.security.ssl.SSLTransport.decode(SSLTransport.java:152)
        at sun.security.ssl.SSLSocketImpl.decode(SSLSocketImpl.java:1397)
        at sun.security.ssl.SSLSocketImpl.readHandshakeRecord(SSLSocketImpl.java:1305)
        at sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:440)
        at com.microsoft.sqlserver.jdbc.TDSChannel.enableSSL(IOBuffer.java:1753)
        ... 111 common frames omitted
```
关键日志
`javax.net.ssl.SSLHandshakeException: The server selected protocol version TLS10 is not accepted by client preferences [TLS12]`

原因是openJDK不支持TLS1.0

#### 0.0.13. 解决方案
* 方案一：修改security文件，将`jdk.tls.disabledAlgorithms`改为如下
```conf
# jdk.tls.disabledAlgorithms=SSLv3, TLSv1, TLSv1.1, RC4, DES, MD5withRSA, \
#    DH keySize < 1024, EC keySize < 224, 3DES_EDE_CBC, anon, NULL, \
#    include jdk.disabled.namedCurves
# override properties of java.security , above is the original value
jdk.tls.disabledAlgorithms=SSLv3, RC4, DES, MD5withRSA, \
    DH keySize < 1024, EC keySize < 224, 3DES_EDE_CBC, anon, NULL, \
    include jdk.disabled.namedCurves
```
* 方案二：指定JVM启动参数 `-Djava.security.properties=$securityPath` securityPath 内容为方案一中内容
仅适用openJDK

```shell
#!/bin/bash
jdktype=`java -version 2>&1 |grep openjdk`
echo $jdktype
# 判断JDK类型
if [ -n "$jdktype" ]; then
    -Djava.security.properties= \
else
    echo "no "
fi

```

### 0.0.14. iframe 嵌入自签证书https打不开问题

#### 0.0.14.1. 解决方案
* 先打开一次再访问
* 改为http
* 浏览器导入根证书
* windows可以右键快捷方式在`目标`的最后面添加` --test-type  --ignore-certifcate-errors`


### 0.0.15. -bash: fork: retry: Resource temporarily unavailable.

#### 0.0.15.1. 问题
现网有个web服务挂了，看日志java执行cmd相关命令`Resource temporarily unavailable.`
重启服务也失败。

执行 `ps -ef | grep test | wc -l` test用户有25万+进程

#### 0.0.16. 问题原因
C端排查是C端有个服务异常，导致很多僵尸进程。pkil 掉就可以

#### 0.0.17. 其他解答
```log
最近在使用虚拟机环境做测试时，常常遇到-bash: fork: retry: Resource temporarily unavailable.
字面意思是资源限制，进程数开的不够大，直接ulimit -u 修改最大进程数之后如故，进而修改/etc/security/limits.conf文件的nproc也一样，无奈只有少开几个服务了.
后面发现一个运维分享上提到在/etc/security/limits.d目录下还有一个地方限制了nproc，打开90-nproc.conf修改nproc值后立马生效，以后再也不用担心开的进程太多报资源不足的错了
————————————————
版权声明：本文为CSDN博主「jq597」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/jq_develop/article/details/52043162
```
