---
layout:     post
title:      Mask RCNN
subtitle:   without bells and whistles
date:       2020-02-10
author:     Simplestory
header-img: img/set_of_rcnn.jpg
catalog: False
tags:
    - Deep Learning
---

>当前大部分的目标检测/分割模型是基于Fast/Faster RCNN和FPN，作者主要提供了一个可比的框架用于实例分割，即Mask R-CNN。

## Introduction

mask rcnn是通过在faster rcnn基础上，加一个分支用于并行地预测分割模板。该分支其实是一个小型的FCN网络，作用于每个ROI区域。

---
- 这里小提一下fast/faster rcnn。fast rcnn在rcnn基础上引入了ROIPool；faster rcnn在fast rcnn的基础上引入了RPN。

实例分割是在像素级别上实现划分对象轮廓。常用的策略有两种：

1. 分割候选，即分割先于识别，先划分出候选的分割区域，再对区域进行类别识别从而达到实例分割的目的。这种方法速度慢准确率低。
2. 语义分割。这个与实例分割不太一样，语义分割只划分同一类别的对象，而实例分割对同一类别的对象也要划分。所以这种方法会从按像素分类的结果开始，尝试将相同类像素分割为不同实例，即在语义分割的基础上实现实例分割。

mask rcnn是基于实例优先的策略的，并且与分类和框回归同时进行。

## 模型关键

mask rcnn采用与faster rcnn相同的二阶段结构。第一阶段与faster rcnn一致，为RPN结构；第二阶段为并行的三个分支：分类，框回归，分割模板。

在训练中，模型对每个roi采用多任务损失函数：

$$
L = L_{cls}+L_{box}+L_{mask}
$$

其中$L_{cls}$为类别损失，$L_{box}$为目标框回归损失，$L_{mask}$为模板损失。mask分支针对每个RoI区域都会得到一个$Km^2$维度的结果，$K$为类别数，$m$则是RoI的分辨率。作者在每个像素上都应用了sigmoid，并将mask损失函数定义为平均二分类交叉熵损失函数。$L_{mask}$只计算与当前RoI关联的真实例损失。

与其它分支不同，mask分支保留了输入图像的空间信息，实现了像素级的对应，这要求roi特征能很好地对齐并保留先前的像素对应空间位置。此前faster rcnn有一步roipool的操作对roi特征图进行了量化。这些量化会引入roi区域与提取特征之间的不对齐性，这对分类结果可能没有影响，但对像素级的分割任务有着很大的负面影响。所以作者去除了roipool里的量化操作，提出了ROIAlign层。该网络层可以对齐输入图像与提取的特征。它避免了roipool中所有的量化操作，取而代之的是双线性差值，利用双线性差值来计算对应点的像素值，如下图所示：

![roialign](https://raw.githubusercontent.com/simplestory/simplestory.github.io/master/img/2020-02-10/maskrcnn_roialign.png)

roialign的提出可以说是这篇论文的一大贡献，前期的roipool在实例上执行的核心操作是粗略的空间量化以进行特征提取，而roialign则忠实地保留了确切的空间位置，同时roialign对最大/平均池化不敏感。它极大程度了解决了使用大步长特征的检测和分割长期面临的问题

## 主要结构

为了证明该模型的通用性，作者实例化了多个不同结构的mask rcnn。主要区别在于模型的backbone和检测头网络。

**对于backbone。**作者主要评估了深度为50层和101层的resnet以及resnext网络。论文里作者采用了$network-depth-features$命名法来命名网络。

---
- 这里举例说明一下$network-depth-features$命名法。在原先faster rcnn的实现中，其特征提取部分是在backbone的最后第四段进行的，称为C4，而这个backbone采用的是resnet-50，所以整个backbone表示为$ResNet-50-C4$

作者还尝试了FPN结构来提取ROI特征。

**对于模型检测头网络。**作者选用faster rcnn with resnet和faster rcnn with fpn的检测头，再加上一个只包含卷积层的mask分支。细节附上论文图例：

![head architecture](https://raw.githubusercontent.com/simplestory/simplestory.github.io/master/img/2020-02-10/maskrcnn_head_architecture.png)

## 实现细节

模型训练阶段。训练采用的超参数与fast/faster rcnn一致。模板损失$L_{mask}$只定义在正例的roi上，(正反roi比例为1：3)。rpn的anchors采用5个尺度和3个长宽比。为了后续实验的方便，作者对rpn进行了单独训练。

模型推断阶段。经过nms后，模型的mask分支只应用于得分最高的100个检测框。mxm的浮点型模板输出要重建为roi尺寸大小并用0.5的阈值来进行二值化。由于mask分支并非应用于全部的检测框，所以mask rcnn在faster rcnn的基础上只增加了少量的开销。

更多具体的细节还是要看回原论文以及相关源代码

## 致谢
本文主要参考自以下内容

>[Mask R-CNN](http://cn.arxiv.org/pdf/1703.06870v3)