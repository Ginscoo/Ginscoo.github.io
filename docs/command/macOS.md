
### mac 配置.bash_profile不生效问题
mac系统中配置了环境变量只能在当前终端生效，切换了终端就无效了，查了下问题所在。mac系统会预装一个终极shell - zsh，环境变量读取在 .zshrc 文件下。
```Shell
切换终端到bash
chsh -s /bin/bash
切换终端到zsh
chsh -s /bin/zsh

# 创建新的zsh环境变量文件
vi ~/.zshrc
# 填写环境变量之后执行
# 使环境变量生效
source .zshrc
```

### 清除DNS缓存
|MACOS VERSION|COMMAND|
|  ----  | ----  |
|macOS 12 (Monterey)|sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder|
|macOS 11 (Big Sur)|sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder|
|macOS 10.15 (Catalina)|sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder|
|macOS 10.14 (Mojave)|sudo killall -HUP mDNSResponder|
|macOS 10.13 (High Sierra)|sudo killall -HUP mDNSResponder|
|macOS 10.12 (Sierra)|sudo killall -HUP mDNSResponder|
|OS X 10.11 (El Capitan)|sudo killall -HUP mDNSResponder|
|OS X 10.10 (Yosemite)|sudo discoveryutil udnsflushcaches|
|OS X 10.9 (Mavericks)|sudo killall -HUP mDNSResponder|
|OS X 10.8 (Mountain Lion)|sudo killall -HUP mDNSResponder|
|Mac OS X 10.7 (Lion)|sudo killall -HUP mDNSResponder|
|Mac OS X 10.6 (Snow Leopard)|sudo dscacheutil -flushcache|
|Mac OS X 10.5 (Leopard)|sudo lookupd -flushcache|
|Mac OS X 10.4 (Tiger)|lookupd -flushcache|