## 启用了不安全的“OPTIONS”HTTP方法 - OPTIONS *

### 问题说明
当发起`options * `请求时，响应报文请求头`Allow`包含`delete`方法，该方法被认为是危险的,部分漏扫工具会认为其用了WebDAV
```http request
OPTIONS * HTTP/1.1
Host: 127.0.0.1:8080
Connection: keep-alive
sec-ch-ua: "Chromium";v="100"
sec-ch-ua-mobile: ?0
User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36
sec-ch-ua-platform: "Windows"
Accept: */*
Accept-Language: en-US
Sec-Fetch-Site: same-origin
Sec-Fetch-Mode: no-cors
Sec-Fetch-Dest: script
Content-Length: 0
```

```http responsse
HTTP/1.1 200 
Allow: GET, HEAD, POST, PUT, DELETE, OPTIONS
Content-Length: 0
Date: Thu, 04 May 2023 03:04:27 GMT
```
### 请求构造
`curl -k -i --request-target "*" -X OPTIONS http://localhost:8080`
通过构造请求进行源码debug
### 问题排查
通过源码debug，tomcat会对`options *`进行特殊处理，该实现在`org.apache.catalina.connector.CoyoteAdapter`类中，代码如下
```Java
 // Check for ping OPTIONS * request
        if (undecodedURI.equals("*")) {
            if (req.method().equalsIgnoreCase("OPTIONS")) {
                StringBuilder allow = new StringBuilder();
                allow.append("GET, HEAD, POST, PUT, DELETE");
                // Trace if allowed
                if (connector.getAllowTrace()) {
                    allow.append(", TRACE");
                }
                // Always allow options
                allow.append(", OPTIONS");
                res.setHeader("Allow", allow.toString());
            } else {
                res.setStatus(404);
                res.setMessage("Not found");
            }
            connector.getService().getContainer().logAccess(
                    request, response, 0, true);
            return false;
        }
```
当请求为 `options *`，固定返回`GET, HEAD, POST, PUT, DELETE`.

### 解决方案
* 解释说明，该问题非问题，是tomcat默认行为
* 修改tomcat源码