---
title: Java jar 包打包成 exe 应用程序
date: 2024-01-08 17:13:04
tags: [Java]
---

当我们完成了 Java 程序并打成了 Jar 包，即可让别人引用或运行，为什么还要将 jar 包打包成 exe？   

这是因为，jar 包需要在 JRE 的环境下才能运行，而在某些情况下我们需要让程序在无 JRE 的环境下运行。比如我们要把程序发给朋友使用，我们肯定不能要求朋友去安装 JDK 或者 JRE 吧，朋友一听使用这玩意儿还要那么麻烦，那肯定就不想使用了呀。所以说，像这种情况，我们要把 jar 包连同 JRE 一起打包到 exe 中，这样别人直接运行 exe 就可以了。   

接下来就详细说一下将 jar 包打包成 exe 的步骤。   


## 前置准备

1. 准备好自己的程序 jar 包，确定 jar 包没有问题，在命令行中 `java -jar my.jar` 能够运行。

2. 下载安装 [exe4j](https://www.ej-technologies.com/download/exe4j/files) 和 [inno setup](https://jrsoftware.org/isdl.php)。前者是将 jar 包转换成 exe 的工具，注意这里的 exe 仅是由 jar 包转换而成的，并没有包含 JRE 进去，因此到这一步还不能结束。后者是将 exe 和 JRE 打包成一个安装程序的工具。   
> 注意，exe4j 要使用注册码激活，不然转换后的 exe 启动时都会有弹窗。注册码网上直接搜即可，这里我用的是 `A-XVK258563F-1p4lv7mg7sav`。   


## exe4j 打包 jar

理论上来说，直接跟着软件指引打包即可。但是，对于初用者来说，可能会在一些选项犹豫不决，因此这里直接将整个过程完整走一遍。   

1. 打开 exe4j 软件，若有之前保存好的 exe4j 配置，则可以加载配置文件，若没有，则直接下一步。    
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/exe4j安装之加载配置文件.png" width="100%"></div>

2. 选择打包的类型，我们要将 jar 包转换成 exe，所以要选择 "JAR in EXE" mode。  
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/exe4j打包模式.png" width="100%"></div>

3. 输入项目名称和输出路径。 
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/exe4j项目名称和项目导出路径.png" width="100%"></div>

4. 可执行类型选择 GUI，输入应用名称，设置应用图标。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/exe4j程序信息设置.png" width="100%"></div>

5. 添加虚拟机参数 `-Dappdir=${EXE4J_EXEDIR}`，添加 jar 包和程序主类。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/exe4j添加虚拟机参数jar包主类.png" width="100%"></div>

6. 填写程序要求的 JDK 版本。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/exe4jJDK版本要求.png" width="100%"></div>

7. 选中 Search sequence，添加 JRE 目录。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/exe4j添加JRE目录.png" width="100%"></div>

8. 选择虚拟机类型，对于桌面应用程序和小型应用程序来说一般是 Client HotSpot VM。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/exe4j虚拟机类型选择.png" width="100%"></div>

9. 之后可以一直默认下一步，直至编译完成，在退出时可以保存配置信息，方便后面复用。  
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/exe4j完成界面.png" width="100%"></div>

最终我们在输出目录可以看到一个 exe 程序生成了，双击就可以运行。但注意，这里的 exe 还是没封装进 JRE。


## inno setup 打包 exe 和 JRE

1. 打开安装好的 inno setup 中的 Compil32.exe 程序，若有之前保存好的配置可以加载，否则就通过脚本向导 Script Wizard 新建一个。 
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup加载配置文件或新建配置.png" width="70%"></div>

2. 填写应用的名称、版本等信息。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup设置应用名称和版本.png" width="70%"></div>

3. 设置应用目录文件夹名称，这里默认即可。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup应用目录文件夹名称.png" width="70%"></div>

4. 选择要打包的 exe 程序，在这里也就是之前 exe4j 生成的 exe 程序。  
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup选择exe程序.png" width="70%"></div>

5. 设置应用程序关联的文件扩展名，默认即可。   
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup配置关联文件.png" width="70%"></div>

6. 设置应用程序快捷方式。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup应用程序快捷方式设置.png" width="70%"></div>

7. 设置程序的安装模式。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup安装模式设置.png" width="70%"></div>

8. 设置程序的语言。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup安装程序语言设置.png" width="70%"></div>

9. 设置安装程序的名称和输出路径。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup安装程序名称和输出路径.png" width="70%"></div>

10. 之后一直默认下一步，Finish 时，会提示是否编译，选否，因为还需要修改脚本文件。
<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup安装程序完成时编译选否.png" width="50%"></div>

11. 修改脚本文件。    
    - 在 `[setup]` 中添加这一行 `MinVersion=7`，表示安装程序最低支持的系统版本为 Windows7。    
    - 在 `[Files]` 中添加这一行 `Source: "F:\workspace\homework-analysis-tool\app\custom-runtime-1\*"; DestDir: "{app}\custom-runtime-1"; Flags: ignoreversion recursesubdirs createallsubdirs`。
    它表示将 JRE 目录中的所有东西添加到安装后的程序的 `DestDir` 目录中。注意这里是要加 `*`，如果没加 `*`，则可能漏掉一些文件没转移，导致安装后的程序运行不起来。

<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup修改脚本文件.png" width="100%"></div>

12. 编译脚本文件，生成最终的安装程序。

<div align="center"><img src="./Java-jar-包打包成-exe-应用程序/innosetup编译脚本文件.png" width="100%"></div>

最终，我们从设置的输出目录中可以得到最终的安装程序，也是一个 exe 程序。这个程序就可以发送给朋友了，朋友拿到这个程序安装后就可以使用了。