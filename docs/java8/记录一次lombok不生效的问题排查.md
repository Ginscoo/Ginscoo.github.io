使用`lombok`生成的`getter` `setter`方法，在`maven`编译时报错`error: cannot find symbol`

问题原因：
之前在做JSR-269(插件式注解) 相关测试的时候，修改了`maven-compiler-plugin`插件参数如下：
```XML
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.5.1</version>

                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                    <encoding>UTF8</encoding>
                    <proc>none</proc>
                    <fork>true</fork>
                </configuration>
            </plugin>
```
其中增加了`<proc>none</proc>`参数，该参数作用为
* none - no annotation processing is performed.;
* only - only annotation processing is done, no compilation.

当指定`none`的时候，编译插件不会进行`annotation processing`也就是注解处理。由于`lombok`实现原理是基于`JSR-269`注解处理的方式实现的。故而导致`lombok`不生效导致编译报错。

另外以下情况注解也不会生效：
* `idea`未开启`annotation processing`功能