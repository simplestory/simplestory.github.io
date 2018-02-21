---
layout:     post
title:      Ubuntu配置Django
subtitle:   
date:       2018-2-19
author:     Simplestory
header-img: img/2018-2-19-django.jpg
catalog: true
tags:
    - Linux
    - 终端
    - Python
    - django
---

>2018新春之际，鬼知道我经历了些什么，在大年初四推博文。Django其实是在新年前配置好的，当时刚好学到了python做web开发方面的知识就顺手配置了。

**配置使用环境**
- 系统：Ubuntu16.04(LTS)
- python版本：python3.6（使用Anaconda建立虚拟环境）

## 准备工作

#### 卸载旧版本Django

如果你从一个旧版本的Django进行升级，那你需要稍微处理一下旧版本的Django。

1. 之前版本的Django是通过`pip`或`easy_install`安装的，再一次执行`pip`或`easy_install`安装时会自动处理旧版的Django，所以你不用进行处理可以直接进行安装。
2. 之前是通过`python setup.py install`安装的，卸载时就是从python包中删除Django库，Django库的路径可以使用以下命令查找：
```
$ python -c "import django; print(django.__path__)"
```

#### 安装Apache（可选）

如果是将Django用于实际环境而非测试开发环境，则需要安装Apache和mod_wsgi。安装Apache之前需要安装APR、APR-Util和Pcre。

- 安装APR：

下载[APR安装包](http://apr.apache.org/),解压后在解压文件夹（文件夹的名字不要包含版本号）里执行以下命令安装：
```
$ ./configure --prefix=/usr/local/apr
$ make 
$ make install 
```

- 安装APR-Util：

同样下载[APR-Util安装包](http://apr.apache.org/)，解压后在解压文件夹（文件夹的名字不要包含版本号）里执行以下命令安装：
```
$ ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr 
$ make 
$ make install
```

- 安装Pcre：

下载[Pcre安装包](https://ftp.pcre.org/pub/pcre/)，注意是pcre而非pcre2。之后解压并在解压文件夹中执行：
```
$ ./configure --prefix=/usr/local/pcre
$ make
$ make install
```

- 安装Apache2：

下载[Apache2安装包](http://httpd.apache.org/download.cgi#apache24)，解压后进入文件中执行以下命令：
```
$ ./configure --prefix=/usr/local/apache2 --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util/  --with-pcre=/usr/local/pcre
$ make
$ make install
```

#### 安装mod_wsgi

使用以下命令安装：
```
$ sudo apt-get install apache2-dev
$ sudo pip install mod_wsgi
```

## 安装Django

首先创建虚拟环境：

```
$ conda create -n django_py36 python=3.6
```

在虚拟环境中安装Django：

```
(django_py36)$ sudo pip install Django
```

至此，Django安装结束。

## 致谢

> [Django Documentation](https://docs.djangoproject.com/en/2.0/)

> [Apache文档](https://httpd.apache.org/docs/2.4/)

> [fresheer的博客——ubuntu下安装 Apache and mod_wsgi](http://blog.sina.com.cn/s/blog_72b0ebdd0102wz0w.html)