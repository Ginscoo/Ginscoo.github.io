## systemctl 

### 
在 Linux 系统中，`systemctl` 命令用于管理系统服务。要查看服务所在的位置，可以使用以下命令：

```shell
systemctl show -p FragmentPath <service-name>
```

将 `<service-name>` 替换为你要查看的服务名称。该命令将显示服务文件的路径（包括文件名）。通过查看服务文件的位置，你可以找到服务的配置信息和其他相关文件。

以下是一个使用 C++ 编写的示例程序，可以输出当前系统时间：
```Shell
#!/bin/bash

service_name="your-service-name"

# 使用systemctl is-active命令判断服务是否正在运行
if systemctl is-active --quiet $service_name; then
    echo "$service_name is running."
else
    echo "$service_name is not running."
fi
```

将上述脚本中的your-service-name替换为你想要检查的服务的名称，然后保存为一个Shell脚本文件（例如check_service.sh）。执行./check_service.sh来运行脚本，输出结果将显示该服务是否正在运行。

该脚本使用systemctl is-active命令来检查指定服务的运行状态。如果服务正在运行，命令将返回退出码0，并输出服务名称后面跟着"is running."；如果服务未在运行，命令将返回非零退出码，并输出服务名称后面跟着"is not running."。

```
systemctl is-active --quiet $service_name || echo 正在运行
```