### FAQ
#### Git or Version Control - Local change 找不到
* `Setting -> Version Control -> Commit`, 不勾选 `Use non-modal commit interface`
#### 编译时错误或者警告控制台输出乱码
* `Help -> Edit Custom Options Properties`,增加 `-Dfile.encoding=UTF-8`
* 猜测原因是IDEA启动时未指定编码信息，故与系统编码保持一致（windows中文系统默认为`GBK`编码）,当以UTF-8编码进行编译在控制台会以`GBK`编码输出,从而导致乱码
