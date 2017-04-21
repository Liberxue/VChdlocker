
## # VChdlocker
##### vc和汇编（nasm）编写的硬盘锁
###### 主要原理：
>The computer post board memory enters hard disk time for Windows startup deletion and partition table hard disk MBR XOR encryption

###### 请勿用于非法勒索谢谢
###### 此代码和原理在网上学习不少大神和方法，找不到署名，再次表示感谢。

注释说明：
---
- [x] 表示项目必须运行中必须要使用的   
- [ ] 表示项目在debug重生成的

#### **开发工具Visual Studio 2015 vc sdk **

文件目录
----
- [x] Config.ini
- [ ] Debug
- [ ] LICENSE
- [ ] README.md
- [x] bin.h
- [ ] hi013.VC.db
- [ ] hi013.sln
- [ ] hi013.vcxproj
- [ ] hi013.vcxproj.filters
- [x] main.cpp
- [x] nasm
- [x] 解锁密码为CaM加上Config.ini中的psw的值


文件名  | 备注说明 
---|---
Config.ini | 解锁密码为CaM加上Config.ini中的psw的值
Debug | 生成调试
bin.h | nasm二进制文件copy进去
main.cpp | vc运行包含异或加密等主文件
nasm | nasm编译工具

------
nasm 使用方法
----


```
nasm.exe bin.asm -o bin
```
