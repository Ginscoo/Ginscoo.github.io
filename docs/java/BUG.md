### 0.0.1. Process#waitFor() 阻塞
#### 0.0.1.1. 问题
某客户现场，java调用python脚本一直阻塞.重启后就好。

#### 0.0.1.2. 问题排查
排查日志：重启后一段时间调用就好，随后某一次又会卡住，后续的调用也会一直卡住。

#### 0.0.1.3. 问题原因
调用时未及时读取输入流导致缓存区满了

#### 0.0.1.4. 解决方案
* `Process#getInputStream()`及时读取缓冲区数据
* `Process#destroy`结束时手动调用销毁方法，销毁进程

### 0.0.2. Zip4J压缩后解压失败
#### 0.0.2.1. 问题
某次项目功能移植，利用zip4J压缩报表，解压时提示文件已损坏

#### 0.0.2.2. 问题排查
通过日志排查，未发现问题。借助`ChatGPT`通过手写测试用例，模拟压缩过程。

#### 0.0.2.3. 问题原因
`ZipOutputStreamclose()`之前未调用`ZipOutputStream#closeEntry()`导致
原项目用的`2.10+`版本,`close()`时会检查是否`closeEntry()`,目标项目用的`2.5+`版本，需要手动调用

#### 0.0.2.4. 解决方案
* 升级`zip4J`版本到`2.10+`
* `close()`之前`closeEntry()`,这种方式在一些流式压缩场景不适用，如PDF、Word、Http响应流。高版本设计更合理些

### 0.0.3. SpringBean注入为空的问题
#### 0.0.3.1. 问题
有个`Bean` `A` 和`Bean` `B`,其中`B`是`A`的内部类，
当`A`调用`B`中的`a()`,`b()`,`c()`方法时，`a()`,和`b()`中的B注入的Bean都有值，当调用c方法时，对应的bean为空,导致`NPE`

#### 0.0.3.2. 问题排查
通过多次怀疑人生代码修改，最终发现`c()`方法为private

#### 0.0.3.3. 问题原因
`B`作为`A`的内部类未实现接口，B中的方法是通过Cglib进行代理的。
Cglib代理存在如下限制
* final 方法：final 方法是无法被子类覆盖的，因此CGlib无法对其进行代理。
* static 方法：static 方法属于类级别的方法，而不是实例级别的方法，因此CGlib无法对其进行代理。
* private 方法：private 方法是私有方法，只能在类内部访问，因此CGlib无法直接访问和代理这些方法。
* 原生方法（Native methods）：原生方法是通过本地代码实现的方法，无法通过字节码生成的方式进行代理。

#### 0.0.3.4. 解决方案
修改方法为public

### 0.0.4. spring-boot-web x-wwww-form-urlencoded请求参数中文乱码
#### 0.0.4.1. 问题
在写自动化初始环境，某接口使用`x-wwww-form-urlencoded`请求，前端请求正常，后端通过`okhttp3`请求请求参数乱码

#### 0.0.4.2. 问题排查
排查请求头：
* 前端请求头`content-type`为`application/x-wwww-form-urlencoded;charset=utf-8`
* 后端请求头`content-type`为`application/x-wwww-form-urlencoded`
其余一致。

初步怀疑是请求头问题 ，查询`chatGPT`,`application/x-wwww-form-urlencoded`不指定编码，则默认为`UTF-8`。

此时按照目标产品版本写个`demo`表单请求接口，测试结果可正常解码，从而可以判断默认情况下无论是否加`charset=utf-8`，后端都应按照`utf-8`处理。

通过有问题环境和demo环境debug分析，发现如果不指定编码，则默认由`CharacterEncodingFilter`过滤器统一处理编码。而有问题环境自定义一个`Filter`用于处理请求头参数，该拦截器优先级设置为最高。该拦截器会在`CharacterEncodingFilter`之前执行，执行的时候会解析参数，由于`CharacterEncodingFilter`未执行，此时请求头又未设置编码，导致会按照默认的`ISO-8859-1`编码解析，从而导致乱码

``

#### 0.0.4.3. 问题原因
* 自定义过滤器优先级过高，在编码过滤器之前执行导致未正确设置编码类型。
* 自定义过滤器会解析参数，导致在未设置编码的情况下就开始了参数解析

#### 0.0.4.4. 解决方案
* 如果要解析参数一定要在`CharacterEncodingFilter`之后执行防止乱码
* 将自定义过滤器优先级降低，保障后执行