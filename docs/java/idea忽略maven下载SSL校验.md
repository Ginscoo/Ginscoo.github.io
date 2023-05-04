
### idea 运行
在`Preferences -> Build,Execution,Deployment -> Build Tools -> Maven -> Runner`
的 `VM Options`增加参数 `-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true`

### 命令行运行
`mvn install:system -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true`