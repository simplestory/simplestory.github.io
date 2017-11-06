---
layout:     post
title:      Linux下安装OPenCV
subtitle:   
date:       2017-10-20
author:     Simplestory
header-img: img/Linux_OpenCV.jpg
catalog: true
tags:
    - OpenCV
    - Machine Learning
    - Linux
---

>近期由于项目需要，要用到计算机视觉识别，所以折腾起了OPenCV，虽然安装过程曲折漫长，但是配合Python使用起来体验还是相当不错的。
在此记录OpenCV安装过程。

**系统环境：Ubuntu16.04**

**安装软件：OpenCV3.3.0+Python2.7.12**

## 更新系统安装包：

```
$ sudo apt update
$ sudo apt upgrade
```

## 安装一些开发者工具：

```
$ sudo apt-get install build-essential cmake pkg-config
```

其中pkg-config包很有可能已经默认安装了，以防万一，还是将它添加进去。cmake程序是用来之后编译OpenCV的。

```
$ sudo apt-get install libjpeg8-dev libtiff5-dev
$ sudo apt-get install libjasper-dev libpng12-dev
```

以上安装包用于OpenCV处理JPEG，PNG，TIFF等图片。对于视频，可以用以下安装的包进行逐帧处理。

```
$ sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev
$ sudo apt-get install libv4l-dev libxvidcore-dev libx264-dev
```

处理OpenCV GUI操作的模块highgui依赖于GTK库，所以还要安装GTK库

```
$ sudo apt-get install libgtk-3-dev
```

安装优化模块

```
$ sudo apt-get install libatlas-base-dev gfortran
```

安装Python开发相关文件和库

```
$ sudo apt-get install python2.7-dev python3.5-dev
```

## 下载OpenCV源代码：

```
$ cd ~
$ wget -O opencv.zip https://github.com/Itseez/openCV/archive/3.3.0.zip
$ unzip opencv.zip
```

可以检查OpenCV官方在Github上推出的新版本来代替`wget`后面`.zip`前的版本号

传送门：[OPenCV Github](https://github.com/opencv/opencv)

还需要下载opencv_contrib库

```
$ wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/3.3.0.zip
$ unzip opencv_contrib.zip
```

同样可以将版本号替换为新版本

传送门：[opencv_contrib](https://github.com/opencv/opencv_contrib)

**注意替换新版本时要保持你的opencv和opencv_contrib的版本号一致**

## 设置Python环境：

**首先确保你已经安装了pip安装工具**

为了保持系统环境的干净，我决定安装virtualenv和virtuanenvwrapper。这些工具允许你在一个独立于系统的虚拟环境下工作。

安装相关工具：

```
$ sudo pip install virtualenv virtualenvwrappper
$ sudo rm -rf ~/.cache/pip
```

之后我们需要更新一下用户主目录下的`.bashrc`,打开该文件，在文件末尾添加如下内容：

```
# virtualenv and virtualenvwrapper
export $WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
```

最后重新执行`.bashrc`时，可能会报错：

```
/usr/bin/python: No module named virtualenvwrapper  
virtualenvwrapper.sh: There was a problem running the initialization hooks.   
If Python could not import the module virtualenvwrapper.hook_loader, 
check that virtualenvwrapper has been installed for  
VIRTUALENVWRAPPER_PYTHON=/usr/bin/python and that PATH is  
set properly.
```

由于ubuntu安装有两个版本的Python，而安装virtualenvwrapper是用的是pip3，但系统默认运行的是Python2,Python2中缺少一些模块。virtualenvwrapper.sh文件部分代码如下：

```
# Locate the global Python where virtualenvwrapper is installed.  
if [ "$VIRTUALENVWRAPPER_PYTHON" = "" ] then  
    VIRTUALENVWRAPPER_PYTHON="$(command \which python)"  
fi
```

当不存在VIRTUALENVWRAPPER_PYTHON环境时，会默认选择使用`which python`
所以还需要添加环境变量：
```
VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
```

选择依赖的Python版本（Python2或Python3）创建虚拟环境

```
$ mkvirtualenv opencvwork -p python2
```

这里我选择Python2,创建名为opencvwork的虚拟环境,相关目录在`~/.virtualenv`下

然后进入虚拟环境
```
$ workon opencvwork
```

之后终端提示符开头会有相关标识

安装Numpy（在虚拟环境下）

```
$ pip install numpy
```

## 配置编译OPenCV：

**在虚拟环境下**

```
$ cd ~/opencv-3.3.0/
$ mkdir build
$ cd build
$ cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-3.3.0/modules \
    -D PYTHON_EXECUTABLE=~/.virtualenvs/cv/bin/python \
    -D BUILD_EXAMPLES=ON ..
```

如果编译出现错误：`stdlib.h: No such file or directory`

那需要在Cmake选项中添加`-D ENABLE_PRECOMILED_HEADERS=OFF`

安装后返回的界面中Python项应该有Interpreter，Libraries，numpy以及packages path项目列出（对应于你所选的Python版本）

确认CMake执行无误后，就可以编译OPenCV了：
```
$ make -j4
```

其中数字4可以换为你电脑上的cpu核心数

```
$ make clean
$ make
```

执行成功后就可以将OPenCV安装到Ubuntu上：

```
$ sudo make install
$ sudo ldconfig
```

## 结束OPenCV安装：

以上命令均成功执行后，Python+OPenCV相关文件会保存在`/usr/local/lib/python-2.7/site-packages/`
(对应你之前选择的Python版本)

之后创建一符号链接：
```
$ cd ~/.virtualenv/opencvwork/lib/python2.7/site-packages/
$ ln -s /usr/local/lib/python2.7/site-packages/cv2.so cv2.so
```
有时候cv2.so可能会在`/usr/local/lib/python2.7/dist-packages`下

## 简单的检测OPenCV安装状况：

```
$ cd ~
$ workon opencvwork
$ python
Python 2.7.12 (default, Nov 19 2016, 06:48:10) 
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import cv2
>>> cv2.__version__
'3.3.0'
>>>
```

安装成功！

文末附上一OpenCV3.3.0官方教程：
[OpenCV3.3.0](https://docs.opencv.org/master/d9/df8/tutorial_root.html)

## 致谢：
>[Adrian Rosebrock](https://www.pyimagesearch.com/2016/10/24/ubuntu-16-04-how-to-install-opencv/)

>[小小攻城狮](http://blog.csdn.net/github_33934628/article/details/53122208)

>[Hello World](http://blog.csdn.net/mbl114/article/details/78089741?locationNum=3&fps=1)