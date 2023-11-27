### 日志
* 默认
    * /var/log/clickhouse-server/


### 造数据 

```shell
#!/bin/bash

DB_NAME=
TABLE_NAME=
USERNAME=
PASSWORD=

clickhouse-client --port 9000 -d ${DB_NAME} -m -u ${USERNAME} --password "${PASSWORD}" -h 127.0.0.1 --query="select * from ${TABLE_NAME} where access_date = 20231121 limit 4000000 FORMAT CSV " >  input.csv;"

# 设置初始值
counter=20231121
# 开始循环，当 counter 大于等于 1 时执行
for (( ; counter >= 20230401; counter-- )); do
    echo "${counter} , $((counter - 1))"
    sed -i 's/'"${counter}"',/'"$((counter - 1))"',/g'  input.csv 
    clickhouse-client --port 9000 -d ${DB_NAME} -m -u ${USERNAME} --password "${PASSWORD}" -h 127.0.0.1 --query="INSERT INTO ${TABLE_NAME} FORMAT CSV" < input.csv;"

done

rm  -rf input.csv
```

### 常用语句 
* 登录
    - `clickhouse-client --port 9000 -d ${DB_NAME} -m -u ${USERNAME} --password "${PASSWORD}" -h 127.0.0.1`
* 查询分区信息
    - `select partition, rows from system.parts where database = 'xxx' and table = 'xxx' limit 100;`
* 删除表分区
    - `ALTER TABLE 'xxx' DROP PARTITION 'xxx'`
