---
title: Linux配置Tensorflow
date: 2018-02-04
author: Simplestory
header_image: https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/2018-2-4-tensorflow.jpg
toc: true
categories: 2018
tags:
    - linux
    - python
    - tensorflow
---

>套用[TensorFlow中文社区](http://www.tensorfly.cn/)的一句话：TensorFlow，一个用于人工智能的开源神器。

**配置使用环境**
- 系统：Ubuntu16.04(LTS)
- python版本：python3.6（使用Anaconda建立虚拟环境）
- Nvidia卡：Geforce 920M（如果没有Nvidia卡，则只能安装CPU版本）

# Tensorflow安装

tensorflow分为两个CPU/GPU两个版本，我建立了两个python虚拟环境，分别安装了这两个版本。在此记录一下安装的痛苦过程

## tensorflow CPU

1. 建立虚拟环境
```shell
conda create -n tensorflow python=3.6
source activate tensorflow  #进入虚拟环境
```

2. 安装tensorflow
CPU版本的安装还是比较简单的，直接使用pip安装即可

```shell
pip install tensorflow
```
若安装报错，可选择下载安装：
到[pypi](https://pypi.python.org/pypi/tensorflow)选择相应版本下载,在文件放置路径下执行以下命令:

```shell
#这里文件名字以自己的为准
pip install tensorflow-1.6.0rc0-cp36-cp36m-manylinux1_x86_64.whl
```

3. 验证安装

进入pytohn环境中,进行测试:

```shell
$ python

>>> import tensorflow as tf
>>> hello = tf.constant('Hello TensorFlow!')
>>> sess = tf.Session()
>>> print(sess.run(hello))
Hello Tensorflow!
>>> a = tf.constant(12)
>>> b = tf.constant(23)
>>> print(sess.run(a+b))
35
>>>
```

或导入tensorflow模块并运行`sess = tf.Session()`，输出大致如下：

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/tensorflow_cpu.png "tensorflow_cpu")

至此，tensorflow CPU版本安装完成

## tensorflow GPU

这将会是一个苦恼的过程，出错率很高，我折腾了两天才把这个GPU版本装上去了。

### 建立虚拟环境

```shell
conda create -n tensorflow_gpu python=3.6
```

安装tensorflow GPU版本之前要向安装GUDA和cuDNN。CUDA是一种由NVIDIA推出的通用并行计算架构，该架构使GPU能够解决复杂的计算问题。 它包含了CUDA指令集架构（ISA）以及GPU内部的并行计算引擎。cuDNN则是用于深度学习神经网络的GPU加速库，它强调性能、易用性和低内存开销。NVIDIA cuDNN可以集成到更高级别的机器学习框架中。

***

这里有个建议：

大家可以先将[CUDA文档](http://developer.download.nvidia.com/compute/cuda/9.0/Prod/docs/sidebar/CUDA_Installation_Guide_Linux.pdf)下载下来，但是不要急于安装，先将NVIDIA给出的官方指导手册仔细看一下，然后再找几篇好的博客看一下，大致了解一下CUDA的安装过程，对安装过程中可能出现的问题要大致有一个了解。

***

### 安装条件

+ 验证电脑是否有支持CUDA的GPU:

在终端下输入命令`lspci | grep -i nvidia`，查看输出。如果没有输出，可以尝试`update-pciids`（该命令一般在`/sbin`目录下）更新一下电脑的PCI硬件数据库，之后再次输入之前的查询命令。最后输出类似下图，如果你的GPU是来自Nvidia制造商且在[CUDA列表](https://developer.nvidia.com/cuda-gpus)中，则表示你拥有一块支持CUDA的GPU。

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/lspci_nvidia.png "lspci_nvidia")

+ 验证Linux版本是否支持CUDA:

用命令`uname -m && cat /etc/*release`可进行查看(ubuntu16.04受支持)

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/uname_cat.png "uname_cat")

+ 验证系统是否安装gcc:

输入命令`gcc --version`可查看gcc版本，若无安装，按终端提示进行安装即可。

+ 验证系统是否安装了匹配的kernel header和package development：

`uname -r`命令可查看内核版本，之后可运行命令`sudo apt-get install linux-headers-$(uname -r)`进行安装，假如你已经安装了，终端会提示并终止安装。

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/linux_headers.png "linux_headers")

以上各项均符合时，即可开始安装CUDA。

### 安装CUDA

CUDA提供两种安装方式：package manager安装和runfile安装。我在其他博客上看到大多数都选择使用runfile这种安装方式，我也尝试过几次，当最终都失败了，两天的安装时间，大部分都耗在安装CUDA上了。最后我选择package manager安装方式。

- 下载CUDA包：

首先在[CUDA下载页面](https://developer.nvidia.com/cuda-toolkit-archive)上选择CUDA版本,我选择的是CUDA 9.0版本

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/cuda_9_0.png "cuda_9_0")

然后按照页面指示的安装步骤进行安装

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/cuda_install.png "cuda_install")

页面中还有一个path1包是CUDA9.0的补丁,安装好CUDA9.0后可以使用`dpkg -i`命令进行安装

- 配置CUDA:

以上步骤结束后，还需要配置系统环境变量，用超级权限编辑家目录下的`.bashrc`文件，将以下内容添加至文件中，保存退出。

```shell
export PATH="/usr/local/cuda-9.0/bin${PATH:+:${PATH}}"
export LD_LIBRARY_PATH="/usr/local/cuda-9.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
```
之后用命令`source ~/.bashrc`重新载入该文件。

### 验证CUDA的安装

- 查看CUDA版本号：

在终端中输入`nvcc --version`查看输出，若输出为相应的版本号，可进行下一步骤，否则应该卸载并重新安装

***

卸载命令：

`sudo /usr/local/cuda-9.0/bin/uninstall_cuda_9.0.pl`（默认情况下，CUDA卸载脚本位于`/usr/local/cuda-9.0/bin`目录下）；

`sudo /usr/bin/nvidia-uninstall` 卸载nvidia驱动及其配置。

***

- 编译CUDA提供的例子：

一般情况下，CUDA提供的例子放在`/usr/local/cuda-9.0/samples`目录下，可以在该目录下进行编译，也可以将整个目录拷贝到其他地方进行编译。

在`samples/`下执行命令`make`进行编译，编译成功会显示`Finished building CUDA samples`

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/make_samples.png "make_samples")

编译好后，进入目录`/samples/bin/x86_64/linux/release`，执行`./deviceQuery`，结果大致如下：

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/deviceQuery.png "deviceQuery")

然后检查一下系统和CUDA-Capable device的连接情况，执行`./bandwidthTest`命令，输出结果大概如下：

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/bandwidthTest.png "bandwidthTest")

若以上各项均通过，恭喜你，成功安装了CUDA！接下来是安装cuDNN

### 安装cuDNN

首先需要注册一个Nvidia官网帐号用于下载cuDNN包，之后选择相应的安装包下载（注意要适配所安装的CUDA版本）

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/cudnn_download.png "cudnn_download")

下载后用`tar`命令解压，解压后把相应的文件拷贝到对应的CUDA目录下即可

```shell
sudo cp cuda/include/cudnn.h /usr/local/cuda-9.0/include/
sudo cp cuda/lib64/libcudnn* /usr/local/cuda-9.0/lib64/
sudo chmod a+r /usr/local/cuda-9.0/include/cudnn.h
sudo chmod a+r /usr/local/cuda-9.0/lib64/libcudnn*
```

### 安装tensorflow GPU

进入虚拟环境：`source activate tensorflow_gpu`

可以到[pypi](https://pypi.python.org/pypi/tensorflow-gpu)选择相应版本下载，之后用`pip install`安装。

也可以直接用相应的安装包连接进行安装

```shell
$ pip install https://pypi.python.org/pypi/tensorflow-gpu/tensorflow_gpu-1.6.0rc0-cp36-cp36m-manylinux1_x86_64.whl
```

### 验证安装

在虚拟环境下的python中导入tensorflow模块并运行`sess = tf.Session()`，输出大致如下：

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20180204/tf_session.png "tf_session")

OK了，漫长的tensorflow GPU版本安装就结束了，接下来可以实践那些神奇的人工智能算法啦！

# 致谢
> [QLULIBIN——Ubuntu 16.04 上安装 CUDA 9.0 详细教程](http://blog.csdn.net/qlulibin/article/details/78714596)

> [multiangle——ubuntu16.04下安装CUDA，cuDNN及tensorflow-gpu版本过程](http://blog.csdn.net/u014595019/article/details/53732015)

> 安装过程可能会遇到的一些坑以及解决方法：

> [会思考的鱼——Ubuntu16.04安装NVIDIA显卡驱动和CUDA时的一些坑与解决方案](http://blog.csdn.net/chaihuimin/article/details/71006654?locationNum=2&fps=1)

> [ycszen——Ubuntu安装NVIDIA驱动(咨询NVIDIA工程师的解决方案)](http://blog.csdn.net/u012759136/article/details/53355781)

> 一些扩展内容：

> [ma_fighting——Ubuntu下如何查看CPU信息, 包括位数和多核信息](https://www.cnblogs.com/mafeng/p/6558941.html)

> [ZeroZone零域——NVIDIA GPU的计算能力 Compute Capability 一览](http://blog.csdn.net/ksws0292756/article/details/79180816)

> [superPershing——Ubuntu系列切换Intel和NVIDIA显卡](https://segmentfault.com/a/1190000009269284)