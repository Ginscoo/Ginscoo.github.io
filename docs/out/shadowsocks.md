
# Ubuntu OS
    # 安装docker镜像
    sudo curl -sS https://get.docker.com/ | sh
    # 非root用户使用
    sudo usermod -aG docker ubuntu
    # 下载安装脚本
    sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh)"
    # 安装服务
    sudo apt install shadowsocks

    # 启动服务
    sudo ssserver -c /home/gin/ss.conf -d start  

    # 如果报错可考虑 sudo nohup sudo ssserver -c /home/gin/ss.conf start &


# ss配置文件

    {
        "server": "0.0.0.0",
        "server_port": 7789,
        "local_address": "127.0.0.1",
        "local_port": 1080,
        "password": "123456",
        "timeout": 300,
        "method": "bf-cfb",
        "fast_open": false
    }