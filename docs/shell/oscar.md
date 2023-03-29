## oscarDB 安装
```Console
# 解压数据库文件
tar -zxvf shentonng.tar.gz
# 进入安装脚本目录
cd shentong/Disk1
# 静默安装
./setup.bin -f st.properties 
# 等待安装完成后重启服务器
reboot
```
## 产品安装
```Console
# 赋予安装包可执行权限
chmod +x DSM-MgtPlatform-UOS-${version}
# 执行安装包
./DSM-MgtPlatform-UOS-${version}
# 等待安装完成后，开启必要的对外端口
dsm --enable-access-port 
```