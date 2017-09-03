---
layout:     post
title:      pyenv和virtualenv搭建Python虚拟环境（多版本）
subtitle:   
date:       2017-9-2
author:     Simplestory
header-img: img/20170902-python.jpg
catalog: true
tags:
    - Python
---

>为了达到在同一系统环境运行多个不同版本的python环境的目的，我们可以借助pyenv来实现。为了建立一个虚拟的python环境，我们可以借助virtualenv来实现。

**本文所用系统为ubuntu16.04LTS**


## 安装pyenv

1. 安装curl和git-core

```
sudo apt install curl git-core
```

2. 安装pyenv

```
curl -L http://raw.github.com/yyuu/pyenv-installer/master/bin/pyenv-install | bash

#该命令会把pyenv安装到当前用户的`~/.pyenv`目录下
```

之后，将下面代码保存至`~/.bashrc`文件中：

```
export PYENV_ROOT="${HOME}/.pyenv"

if [-d "${PYENV_ROOT" ]; then
	export PATH="${PYENV_ROOT}/bin:${PATH}"
	eval "${pyenv init -}"
if
```

这段代码主要指明pyenv的位置，保存之后就可以在命令行里面运行pyenv命令。保存在`~/.bashrc`文件中是为了每次1用户登录后自动生效。
之后运行一下命令：

```
source ~/.bashrc	#该命令使上面对`~/.bashrc`文件的修改生效
```

3. 安装一些包：

```
sudo apt build-dep pythin2.7	#之后安装其他版本Python时可能需要这些包
```

## pyenv的使用

1. 查看可安装Python：

```
pyenv install --list	#查看有哪些版本的Python可以安装
```

2. 安装某版本的Python：

```
pyenv install <py-version>
#最后的`<py-version>`是所要安装的Python的版本号
```

```
pyenv versions	#查看安装情况，输出结果中带黑点的表示当前使用的Python版本
```

3. 切换Python版本：

```
pyenv global 2.7.12	#将当前的python版本切换至2.7.12
pyenv global system	#切换回系统版本
```

4. 卸载某个Python版本：

```
pyenv uninstall x.x.x
```

## 利用virtualenv

victualenv原本是一个独立工具


[virtualenv官网]：https://pypi.python.org/pypi/virtualen

但按之前的安装方式的话，virtualenv已经作为插件安装好了，可直接使用。

创建Python虚拟环境：

```
pyenv virtualenv 2.7.12 env2712
```

该命令在本机上创建了一个名为env2712的虚拟环境，虚拟环境的真实目录位于：`~/.pyenv/versions/`

**命令中的Python版本号应该是已经安装好的版本（或由pyenv安装）**

创建好后的Python虚拟环境会出现在`pyenv versions`命令的输出中。

## 使用Python虚拟环境

切换到新的Python虚拟环境：

```
pyenv activate <env-name>	#最后一个参数为虚拟环境名字
```

**切换到虚拟环境后所做的操作不会影响真机环境**

切换回系统环境：

```
pyenv deactivate
```

删除虚拟环境，直接上出它所在的目录即可：

```
rm -rf ~/.pyenv/versions/env2712/	#删除env2712虚拟环境
```

## 致谢

本文参考自雷子——晓飞爸，发布于 http://www.cnblogs.com/npumenglei/
如需转载，请注明出处。