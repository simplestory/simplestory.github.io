---
layout: post
title: MobileNetV2
subtitle: Inverted Residuals and Linear Bottlenecks
date: 2020-04-26
author: Simplestory
toc: False
mathjax: true
categories: 2020
tags: deep learning
---

> 不知不觉又积累了好多论文，真是让人憔悴呢。回归正题，神经网络在很多领域已经有了应用，在图像识别领域甚至已经超越人类的能力，而模型准确率的提高带来的是更高的算力要求。在实际工程应用中往往提供不了很高的计算能力，有些甚至在嵌入式平台上运行算法，这意味着那些高大上的算法根本是不可能部署上去的。谷歌继mobilenetv1后提出了其改进版本mobilenetv2，该模型更适合于轻量级部署，在保持运行速度的同时也能拥有能看的准确率。

## 深度可分离卷积

首先先来看一下已经mobilenetv1中使用了的深度可分离卷积。大致逻辑就是将一个普通的卷积计算分为两步来完成：depthwise卷积和pointwise卷积，在达到相同效果的同时降低了计算量。

假设标准卷积的输入是$h_i\times w_i\times d_i$维度的$L_i$，核参数为$K\in R^{k\times k\times d_i\times d_j}$，最后输出为$h_i\times w_i\times d_j$维度的$L_j$。所以标准卷积的计算量为$h_i\times w_i\times k\times k\times d_i\times d_j$。

采用深度可分离卷积后，输入为$h_i\times w_i\times d_i$维度的$L_i$，depthwise卷积核参数为$K_1\in R^{k\times k\times d_i\times d_i}$，pointwise卷积核参数为$K_2\in R^{1\times 1\times d_i\times d_j}$，最后输出也为$h_i\times w_i\times d_j$维度的$L_j$。所以计算量为$k\times k\times h_i\times w_i\times d_i + 1\times 1\times h_i\times w_i\times d_i\times d_j$，即$h_i\times w_i\times d_i\times (k^2 + d_j)$。可以看出与标准卷积的计算量相差$\frac{k^2d_j}{k^2+d_j}$的倍数，所以深度可分离卷积真的是一种高效的卷积设计。

在论文中，mobilenetv2对可分离卷积全程使用$3\times 3$核参数。

## Linear Bottlenecks

姑且叫它线性瓶颈层吧（不知道怎么翻译好。。。）这部分主要是说模型的特征保留能力。一直以来，神经网络中的“mainfold of interest”（应该是有效特征之类的）被认为可以嵌入到低维子空间中，所以就有了通过降低卷积层的维度来降低子空间的维度从而获得更多的有效特征。但是传统的神经网络在实际上在每个坐标转换上都具有非线性（However, this intuition breaks down when we recall that deep convolutional neural networks actually have non-linear per coordinate transformations）。

以ReLU激活函数为例，将其应用于1维空间中的一条直线，在n维空间中会产生射线，实际上一般会产生具有n个接头的分段线性曲线。由ReLU激活函数的曲线也可以看出，深度网络仅在输出域的非零部分具有线性分类器功能。作者在最后给出了模型主要特征位于高维空间的低维子空间中的两点要求：

- 对于ReLU输出结果为非0的情况，ReLU则只是一个简单的线性变换；
- ReLU在input mainfold处于输入空间的低维子空间的前提下，可以保留input mainfold的信息

在假设满足第二点的情况下，我们可以通过在卷积块里插入线性瓶颈层来捕捉有效特征。作者也通过实验表明了加入线性瓶颈层能有效阻止非线性变换破坏过多的特征信息。

线性瓶颈层里有一个重要参数扩展比率$expansion \ ratio$，即输入bottlenck的大小与内部大小之间的比率。

这部分我看得有一些迷茫，还是得多看几遍。

## Inverted residuals

受到bottleneck的启发，bottleneck实际上包含了所有必要的信息，而扩展层仅充当张量的非线性转换的实现细节，所以作者直接在瓶颈之间使用快捷连接的方式。具体如下图所示。

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20200426/inverted_residual.png "inverted_residual")

bottleneck大致的结构如下图所示：

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20200426/bottleneck.png "bottleneck")

## 模型结构

如图

![](https://simplestory-blog-img.oss-cn-guangzhou.aliyuncs.com/in_posts/20200426/mobilenet2.png "mobilenet2")

首先是一个包含有32个卷积核的标准卷积层，之后是19个残差bottleneck模块（但论文表格上却只有17个，官方复现中也是按表格来的）。激活函数使用的是ReLU6，卷积核参数为$3\times 3$。除了第一个bottleneck外，作者在整个网络中都使用了恒定的扩展速率（实验得出5到10之间模型鲁棒性会比较好）

**模型实现中还有一些提升内存效率的操作，具体可以看论文原文。**

最后，针对目标检测领域，作者也修改了SSD网络，提出了SSDLite的轻量级实现。在mobilenetv2上，SSDLite的第一层连接到了mobilenetv2的第15层的扩展（输出跨度维16），其余的SSDLite层连接在最后一层的顶部（输出跨度维32）。

## 致谢

本文主要参考自以下论文

>[MobileNetV2: Inverted Residuals and Linear Bottlenecks](https://arxiv.org/pdf/1801.04381.pdf)
