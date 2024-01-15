---
title: 谈谈 Java9+ 的模块化
date: 2024-01-11 20:24:16
tags: [Java,模块化]
---


这几天，因为打包方面的一点问题，在查资料的过程中，接触到了模块化，顺便也实践了一下，我觉得这是一个挺有用的东西，因此在这里分享一下。

## 什么是模块？

模块是 Java9 中提出的一个新概念，本质上是一个 jar 包，但是它比普通的 jar 包多了一个文件 `module-info.class` 文件，这是模块的核心，也称之为模块描述符——`module descriptor` 。   

在 `module descriptor` 中，定义了以下的信息：
- 模块名称
- 依赖哪些模块
- 导出模块内的哪些包（允许直接 `import` 使用）
- 开放模块内的哪些包（允许通过 Java 反射访问）
- 提供哪些服务
- 依赖哪些服务

理论上，任意一个 jar 文件，只要加上了一个合法的 `module descriptor`，就可以升级为一个模块。而一个项目的多个模块就可以构成了模块系统。   

那么，模块系统到底带来了什么好处？主要有以下三点:
1. 精简了 JRE。这是我认为最大的好处。引入了模块系统后，JDK 自身被划分为很多模块（以 JDK17 为例，划分为了 71 个模块）。通过新增的 `jlink` 工具，开发者可以根据实际应用场景随意组合模块，生成自定义的 JRE。相比于 JDK8 及之前，大大缩小了 JRE 的大小，这也让 Java 对嵌入式应用开发变得更友好。
2. 更好的依赖管理。有了模块系统，Java 可以根据 `module descriptor` 计算出各个模块间的依赖关系，一旦发现循环依赖，启动就会终止。同时，由于模块系统不允许不同模块导出相同的包，所以在查找包时，Java 能够精准的定位到一个模块，从而获得更好的性能。  
3. 更好的安全性。在模块系统引入之前，Java 就只有 4 种包可见性，这也让 Java 的封装性大打折扣。而引入了模块系统之后，利用 `module descriptor` 中的 `export` 关键词，可以精准地控制哪些类可以对外开放使用，哪些类只能内部使用，细化了类的可见性，带来了更好的安全性。   


## 怎么定义模块？

上面提到，模块有一个模块描述符 `module descriptor`，对应于根目录下的 `module-info.class` 文件。它是由 `module-info.java` 文件编译而成的，`module-info.java` 在每个模块项目源码的根目录下，也就是在 `java` 文件夹下。   

`module-info.java` 文件中的语法是这样子的：  

```java
[open] module <moduleName> {
    requires [transitive] <module1>;
    exports <package> [to <module1>,<module2>,...];
    opens <package> [to <module1>,<module2>,...];
    provides <interface | abstract class> with <implClass1>,<implClass2>,...;
    uses <interface | abstract class>;
}
```
<br>

语法解读：  
- `[open] module <moduleName>`：声明一个模块，模块名应全局唯一，不可重复。加上 `open` 关键词表示模块内的所有包都允许通过 Java 反射访问，模块声明体内不再允许使用 `opens` 语句。
- `requires [transitive] <module1>`：声明模块依赖，一次只能声明一个依赖，如果依赖多个模块，需要多次声明。加上 `transitive` 关键词表示传递依赖，比如模块 A 依赖模块 B，模块 B 依赖模块 C，那么模块 A 就会自动依赖模块 C，类似于 Maven。
- `exports <package> [to <module1>,<module2>,...]`：导出模块内的包（允许直接 `import` 使用），一次也是只能导出一个包，如果需要导出多个包，需要多次声明。如果需要定向导出到某个或某些模块，可以使用 `to` 关键词，后面跟上导出的目标模块或模块列表。不在导出包中的类，即使是 `public` 修饰的，其他模块也无法使用它。
- `opens <package> [to <module1>,<module2>,...]`：开放模块内的包（允许通过 Java 反射访问），一次开放一个包，如果需要开放多个包，需要多次声明。如果需要定向开放，同样可以使用 `to` 关键词。
- `provides <interface | abstract class> with <implClass1>,<implClass2>,...`：声明模块提供的 Java SPI 服务，一次可以声明多个服务实现类。
- `uses <interface | abstract class>`：声明模块依赖的 Java SPI 服务，加上之后模块内的代码就可以通过 `ServiceLoader.load(Class)` 一次性加载所声明的 SPI 服务的所有实现类。


## 模块怎么使用？

Java9 引入一系列新的命令和参数用于编译、运行和封装模块，其中最重要的就是两个参数 `--module-path` 和 `--module`。  
- `--module-path`：简写为 `-p`，用来指定模块路径，多个模块之间用 ":"（ Mac 和 Linux 环境下）或者 ";"（ Windows 环境下）分隔。
- `--module`：简写为 `-m`，用来指定待运行模块的主类，输入格式为 `<module>/<main_class>`。

```shell
# 编译模块
javac --module-path <module_path> <module>

# 将 jar 包转换为模块，模块名称 <output_jmod_name> 要与 module-info.java 中定义的模块名称一致
jmod create --class-path <jar_file> <output_jmod_name>

# 运行模块
java --module-path <module_path> --module <module>/<main_class>

# 封装模块进 JRE 
jlink --module-path <moudle_path> --add-modules <module1>,<module2>,... --output custom-jre

## 分析模块依赖的其他模块
jdeps -s --module-path <module_path>  <module>
```

## 自动模块和未命名模块

上面已经提到，我们通过定义 `module-info.java` 文件可以声明一个模块，这种模块也叫做**命名模块**。但是对于 Java8 及之前的老应用，并没有模块信息，这种应该怎么办？答案就是通过 **未命名模块** 和 **自动模块**。  

- **未命名模块**：所有 `--class-path` 下的 jar 文件自动转为未命名模块。未命名模块可以读取到其他所有的模块，并且会将自己包下的所有类都暴露给外界。需要注意的是未命名模块虽然导出了所有的包，但是由于命名模块无法在 `module-info.java` 文件中声明对未命名模块的依赖，因此命名模块无法读取未命名模块。未命名模块导出所有包是为了让其他的未命名模块能够加载这些类。

- **自动模块**：所有 `--module-path` 下的 jar 文件会自动转为自动模块。自动模块可以引用其他所有命名模块的类，并且也会将自己包下的所有类暴露给外界。它跟未命名模块不同的是，虽然都没有 `module-info.java` 文件，但是自动模块会由 JDK 根据 jar 包名自动生成模块名，以允许其他模块使用。生成模块名的规则是：首先会移除文件扩展名和版本号，然后用 "." 替换所有非字母字符。换句话说，自动模块是一种特殊的命名模块，也遵循模块规则，只是模块名是由 JDK 自动生成的。


## 总结

以上就是对 Java9 开始有的模块化的介绍。虽然从引入之后到现在，模块化的使用还不够广泛，但是这并不影响它还是一个好特性，如果能够妥善运用，对开发工作还是大有益处的。


## 参考资料
- [【JDK 11】关于 Java 模块系统，看这一篇就够了](https://emacoo.cn/coding/java-module-system/)
- [Java9模块化遇坑](https://juejin.cn/post/6844903646971297806#heading-3)
- [Java 9模块化系统：构建可扩展的应用程序](http://luomuren.top/articles/2023/07/17/1689574984946.html#toc_h2_2)
- [Java 多个模块 获取当前模块路径 java多模块开发的好处](https://blog.51cto.com/u_16213721/7202551)