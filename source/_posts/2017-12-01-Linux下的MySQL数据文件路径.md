---
title: Linux下的MySQL数据文件路径
date: 2017-12-01
author: Simplestory
toc: False
categories: 2017
tags:
    - linux
    - mysql
---

**Server version: 5.7.20-0ubuntu0.16.04.1 (Ubuntu)**

进入Mysql后,可用如下命令查询相关文件的储存路径:

```sql
show variables like '%dir%';
```

输出如下图:

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20171201/mysql.png "mysql")

通常有:
数据库文件默认位置为: `/usr/share/mysql/`
配置文件: `/etc/mysql/my.cnf`

数据库目录: `/var/lib/mysql`
配置文件: `/etc/share/mysql`(mysql.server命令及配置文件)
mysql相关命令: `/usr/bin`
启动脚本: `/etc/init.d/`

**mysql的一种安全启动方式: /usr/bin/mysqld_safe-user=root&**
