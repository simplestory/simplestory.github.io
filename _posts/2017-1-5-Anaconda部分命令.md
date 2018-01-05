---
layout:     post
title:      Anaconda部分命令
subtitle:   
date:       2017-1-5
author:     Simplestory
header-img: img/Anaconda.jpg
catalog: true
tags:
    - Python
    - 终端
---

>Anaconda是一个用于科学计算的Python发行版，支持 Linux, Mac, Windows系统，提供了包管理与环境管理的功能，可以很方便地解决多版本python并存、切换以及各种第三方包安装问题。Anaconda利用工具/命令conda来进行package和environment的管理，并且已经包含了Python和相关的配套工具。在这里我记下一些conda常用的命令，方便日后查看。

## Anaconda安装

关于Anaconda的安装，可以参考官网[Anaconda](https://www.anaconda.com/download/)

## Conda环境管理

Conda的环境管理功能允许我们同时安装若干不同版本的Python，并能自由切换。

```
# 创建一个新的虚拟Python环境
# 以下命令创建一个python3.5版本的环境
# 环境名字为python_env
conda create -n python_env python=3.5

# 激活虚拟环境python_env
activate python_env # for windows
source activate python_env  # for Linux or Mac

# 返回原环境
deactivate python_env   # for windows
source deactivate   # for Linux or Mac

# 删除虚拟环境
conda remove --name python_env --all

# 查询目前拥有的虚拟环境，包括原环境
conda info -e
```

## Conda包管理

这部分的功能与`pip`类似。

```
# 查看已安装的packages
# 最新版的conda是从site-packages文件夹中搜索已安装的包
# 可以显示通过各种方式安装的包，并不依赖于pip
conda list

# 查看某个指定环境已安装包
conda list -n <env-name>

# 安装包，以numpy为例
conda install numpy

# 安装packages
# 没有 -n 选项时则直接安装在当前活跃环境中
# 也可以通过 -c 选项指定通过某个通道安装
conda install -n <env-name> <packages-name>

# 更新packages
conda update -n <env-name> <packages>

# 删除packages
conda remove -n <env-name> <packages>
```

conda将conda、python等都视为package，因此，完全可以使用conda来管理conda和python的版本

```
# 更新conda
conda update conda

# 更新anaconda
conda update anaconda

# 更新python
# 假设当前环境的python版本为python3.5,则会升级为pytohn3.5.x的最新版本
conda update python

# 在当前环境下安装anaconda
conda install anaconda

# 在创建虚拟环境的同时安装指定包,可包括anaconda
conda create -n python_env python=3.5 <packages-name>
```

## 配置源

Anaconda.org的服务器在国外，所以由于某种原因`conda`的下载速度很慢。配置国内源后，下载速度会有明显改善

[清华大学镜像](https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/)

```
# 添加Anaconda的TUNA镜像
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
 
# 设置搜索时显示通道地址
conda config --set show_channel_urls yes
```

执行完上述命令后，会生成~/.condarc(Linux/Mac)或C:UsersUSER_NAME.condarc文件(Windows)，记录我们对conda的配置。


**附上一份`Conda`文档**

[Conda](https://conda.io/docs/user-guide/index.html)