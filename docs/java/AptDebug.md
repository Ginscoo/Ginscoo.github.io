## mvnDebug断点不生效
* annotation processor调试，通过mvnDebug远程调试方式，断点不生效。

## Idea build方式 - 2022.2
* 编辑custom VM Options增加 `-Dcompiler.process.debug.port=8000`
* `Action` 搜索`Debug build process` 打开，重启后需要重新打开
* `Preference  -> Build,Execution,Deployment -> Compiler -> Shared build process VM options `增加 `-Xdebug -Djps.track.ap.dependencies=false`
* 通过build方式构建项目即可