### HSTS

```Console
sudo killall nsurlstoraged
rm -f ~/Library/Cookies/HSTS.plist
launchctl start /System/Library/LaunchAgents/com.apple.nsurlstoraged.plist
```

`rm -f ~/Library/Cookies/HSTS.plist ` 在`Catalina `版本无权限操作，
可先将文件拷出，再用Xcode编辑，搜索想移除HSTS的网站将`HSTS host`的值改为0，再覆盖原文件即可

### 关于 Mac 上的系统完整性保护
OS X El Capitan 及更高版本内含安全技术，有助于保护 Mac 免受恶意软件的侵害。

系统完整性保护是 OS X El Capitan 及更高版本所采用的一项安全技术，旨在帮助防止潜在恶意软件修改 Mac 上受保护的文件和文件夹。系统完整性保护可以限制 root 用户帐户，以及 root 用户能够在 Mac 操作系统的受保护部分完成的操作。

在实施系统完整性保护之前，root 用户不受任何权限限制，因此可以访问 Mac 上的任意系统文件夹或应用。如果您在安装软件时输入了管理员用户名和密码，这个软件就能获得 root 级访问权限。这样使软件能够修改或覆盖任意系统文件或应用。

系统完整性保护包含对以下系统部分的保护：

* /系统
* /usr
* /bin
* /sbin
* /var
* OS X 预装的应用

第三方应用和安装器可以针对以下路径和应用继续完成写入操作：

* /应用程序
* /资源库
* /usr/local

仅当进程拥有 Apple 签名并拥有对系统文件（如 Apple 软件更新和 Apple 安装器）完成写入操作的特殊授权时，系统完整性保护才会允许它修改这些受保护部分。从 Mac App Store 下载的应用兼容系统完整性保护。升级至 OS X El Capitan 或更高版本时，与系统完整性保护冲突的其他第三方软件可能会被忽略<sub></sub>。

系统完整性保护还有助于防止软件选择启动磁盘。要选择启动磁盘，请从苹果菜单中选取“系统偏好设置”，然后点按“启动磁盘”。或者，在重新启动时按住 Option 键，然后从启动磁盘的列表中进行选择。