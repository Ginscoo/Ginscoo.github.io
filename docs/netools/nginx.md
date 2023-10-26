## 编译https及stream模块
```sh 
 ./configure --sbin-path=/usr/local/nginx/nginx  \
            --conf-path=/usr/local/nginx/nginx.conf \
            --pid-path=/usr/local/nginx/nginx.pid \
            --modules-path=/usr/local/nginx/modules  \
            --with-http_realip_module \
            --with-stream=dynamic \
            --with-stream_ssl_module 
            --with-stream_realip_module
 ```