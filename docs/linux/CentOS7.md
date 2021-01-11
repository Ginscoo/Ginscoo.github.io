## 系统设置
### 配置静态IP地址
    # vi /etc/sysconfig/network-scripts/ifcfg-eth0
    TYPE=Ethernet
    BOOTPROTO=none
    DEFROUTE=yes
    # static ip
    IPADDR=192.168.16.16
    # netmask prefix
    PREFIX=24
    GATEWAY=192.168.16.1
    DNS1=192.168.16.254
    DNS2=114.114.114.114
    IPV4_FAILURE_FATAL=no
    IPV6INIT=yes
    IPV6_AUTOCONF=yes
    IPV6_DEFROUTE=yes
    IPV6_FAILURE_FATAL=no
    IPV6_ADDR_GEN_MODE=stable-privacy
    NAME=ens192
    UUID=0d3ae011-75f9-425e-a958-815cc70948e5
    DEVICE=ens192
    # start 
    ONBOOT=yes

### 修改DNS服务器
    # 直接生效
    /etc/resolv.conf
### IP 查看
    # 查看本机 IP
    ip a
    # 查看路由信息
    ip -r

### 阿里云 yum 源设置
     # 或者直接先下载好阿里云repo再替换/etc/yum.repos.d/CentOS-Base.repo
     wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
     yum clean all
     yum makecache

# 软件安装
## Gitlab-runner 安装
    wget -O /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

    # 这一步要先执行，生成启动脚本service时会用到 gitlab-runner 所在位置，若先安装再移动会导致脚本内启动位置错误
    mv gitlab-runner-linux-amd64 /usr/local/bin/gitlab-runner
    chmod +x /usr/local/bin/gitlab-runner
    
    useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
    gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
    gitlab-runner start
    gitlab-runner register

## Java 安装
    # 是否安装
    rpm -qa|grep java
    # 卸载已安装
    rpm -e --nodeps java-1.8.0-openjdk-1.8.0.131-11.b12.el7.x86_64
    # 验证是否还存在
    rpm -qa|grep java
    # 查看可安装JDK
    yum search java | grep -i --color jdk
    # yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
    # 或者如下命令，安装jdk1.8.0的所有文件
    yum install -y java-1.8.0-openjdk*
 ## Maven 安装
    wget https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
    mv apache-maven-3.6.3-bin.tar.gz tools/dsm/
    tar -xf apache-maven-3.6.3-bin.tar.gz 
    cd apache-maven-3.6.3/
    ln -s /home/tools/dsm/apache-maven-3.6.3/bin/mvn /bin/mvn
    mvn install -pl frontend,backend -am -Dmaven.test.skip=true

## yum 直接安装
    yum install git -y
    yum install telnet -y
    yum install wget -y
