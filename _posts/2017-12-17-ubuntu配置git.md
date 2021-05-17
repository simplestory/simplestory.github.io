---
layout:     post
title:      "Ubuntu配置Git"
subtitle:   
date:       2017-12-17
author:     "Simplestory"
header-style: text
catalog:
tags:
    - Git
    - 终端
---

> 由于本人手残将电脑系统搞坏了，不得不重装系统。在体验了什么是“断、舍、离”之后，我卡在了ubuntu配置git上面了，后来我百度解决了，在此记录这一配置过程以防万一。

## 安装git

首先是安装git，大多数Linux系统都会预装git，但版本可能不高，需要升级更新。我的ubuntu16.04并没有预装git，可以用apt安装

```shell
sudo apt-get install git
git --version
```

结果如图：

![install git](/img/in_posts/20171217/install.png)

## 配置git

输入以下指令进行配置：

```shell
git config --global user.name "<name>"
git config --global user.email "<email>"
```

结果如下图：

![config git](/img/in_posts/20171217/config.png)

## 创建公钥

```shell
ssh-keygen -C '1195997479@qq.com' -t rsa
```

**ssh与-keygen之间，会在用户目录`~/.ssh/`下建立相应的密钥文件**

结果如下图：

![ssh git](/img/in_posts/20171217/keygen.png)

创建完公钥，需要上传。使用`cd ~/.ssh`进入`~/.ssh`文件夹，使用`cat`查看`id_rsa.pub`内容。
结果如图：

![ssh id](/img/in_posts/20171217/id_rsa.png)

访问github帐号，添加ssh key，标题栏可以随意填写，内容将`cat`的内容复制进去即可。

上传完后使用以下命令进行测试：

```shell
ssh -v git@github.com
```
看到以下信息则表示验证成功：

![git](/img/in_posts/20171217/success.png)