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