## 上传文件
```Shell
#!/bin/bash

ftp -n <<EOF
open ${FTP_SERVER}
user username passwd

binary

prompt
cd  target_folder
lcd  local_dir

mput xxxx
close
bye
EOF
```

## 下载文件
```sh
#  wget ftp://test:111111@192.168.16.10:22/home/test.tar.gz
wget ftp://${username}:${password}@host:${port}${path}
```