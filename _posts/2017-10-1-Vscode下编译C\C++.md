---
layout:     post
title:      Vscode下编译C/C++
subtitle:   
date:       2017-10-1
author:     Simplestory
header-img: img/20171001-Vscode.jpg
catalog:    false
tags:
    - C/C++
---

>Visual Studio Code是微软推出的一款轻量型编辑器,通过安装各种插件可以转变成一款强大的多语言,跨平台的编译器.近日,由于实践需要,需要在调试一些C/C++代码,于是折腾起Vscode,以下是记录折腾过程中困扰着我的问题.

**本文所用系统为ubuntu16.04LTS**

关于Vscode在linux系统下的安装过程我就不详细说明了,度娘有大把资源.

## 安装C/C++插件

用`ctrl+shift+P`调出命令行,搜索C++,找到微软官方发布的那个插件,如图:

<center>
![C\C++](https://raw.githubusercontent.com/simplestory/simplestory.github.io/master/img/2017-10-01/2017-10-01-C++.jpg)
</center>

## 编辑C/C++源文件

用Vscode打开一个目录,因为编译C/C++时会产生一些配置文件,针对于目录下的文件.

现在写一个简单的cpp文件实验一下:

```
// hello.cpp

# include<iostream>
using namespace std;

int main()
{
    cout << "Hello World!" << endl;
    return 0;
}
```

## 编译C/C++源文件

保存编写好cpp源文件,若直接进行编译运行,Vscode会报错,原因是还没配置好相关文件.

1. 配置launch.json文件

根据报错信息,选择C/C++(GDB)打开相关launch.json文件,更改`"program"对应段的代码为:
`"${workspaceRoot}/${fileBaseNoExtension}.out"`
有些可能还需要修改`"cwd"`项,改为:`"${workspaceRoot}"`
修改后如下图:

<center>
![launch.json](http://raw.githubsercontent.com/simplestory/simplestory.github.io/master/img/2017-10-01/2017-10-01-launch_json.jpg)
</center>

2. 配置tasks.json文件

配置好launch.json文件后依然不能顺利执行编译,还需要配置tasks.json文件
用`ctrl+shift+P`打开命令行,输入`tasks runner`,选择`configure tasks`项回车打开
修改`"task"`项下的`"taskName"`,`"command"`并添加`"args"`项,结果如图:

<center>
![tasks.json](http://raw.githubsercontent.com/simplestory/simplestory.github.io/master/img/2017-10-01/2017-10-01-tasks_json.jpg)
</center>

两个文件均配置并保存好后即可编译运行,点击调试,可以看见终端一闪而过,在windows下我们为了看清终端显示的结果,会在cpp文件中加一语句:`system(pasue)`,但在linux系统中`pasue`不再是一条命令,故并不生效.可以改用`getchar()`实现相同功能.

```
# include<iostream>
# include<stdio.h>
using namespace std;

int main()
{
    cout << "Hello World!" << ehdl;
    getchar();
    return 0;
}
```

附上一张结果图:

<center>
![last](http://raw.githubsercontent.com.simplestory/simplestory.github.io/master/img/2017-10-01/2017-10-01-last.jpg)
</center>
