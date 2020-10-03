---
layout:     post
title:      Efficient模型家族
subtitle:   EfficientX basic family
date:       2020-10-03
author:     Simplestory
header-img: img/2020-10-03/post-bg-2015.jpg
catalog: True
tags:
    - Deep Learning
---

> 在2019年年末和2020年年初，谷歌大脑发表了两篇论文，分别针对图片分类和目标检测领域提出了一个快速准确的模型，并命名为EfficientNet和EfficientDet。作者还通过对模型参数进行调整得到了一系列高效的分类和检测模型。

## EfficientNet

作者通过前人的工作以及自己的实验总结出了两个观点：

- 缩放模型的任一维度（深度、宽度、分辨率）都会提升模型的精度，但对于过大的模型缩放尺度，其精度收益会减少
- 在卷积网络的缩放中，平衡地缩放模型各个维度可以获得更好的精度和速度

### compound scaling

通过上述的两个观点，作者不再使用传统的单一维度的模型缩放，而是对模型的各个维度（深度、宽度和分辨率）进行缩放。

首先对于卷积模型，我们可以表示为：

$$
\mathcal{N} = \underset{i=1...s}{\bigodot}\mathcal{F}_i^{L_i}(X_{\langle H_i, W_i, C_i\rangle})
$$

其中，$\mathcal{F}_i^{L_i}$表示在网络块$i$中，网络层$F_i$重复$L_i$次，而$\langle H_i,W_i,C_i\rangle$表示第$i$层的输入尺寸，$\mathcal{N}$则为整个卷积网络模型。

由上式可以得到抽象后的模型缩放优化问题：

$$
\begin{aligned}
\underset{d,w,r}{max} &\ Accuracy(\mathcal{N}(d,w,r)) \\
s.t. &\ \mathcal{N} = \underset{i=1...s}{\bigodot}\hat{\mathcal{F}}_i^{d\cdot \hat{L}_i}(X_{\langle r\cdot \hat{H}_i, r\cdot \hat{W}_i, w\cdot \hat{C}_i\rangle}) \\
&\ \text{Memory}(\mathcal{N}) \le target\_memory \\
&\ \text{FLOPS}(\mathcal{N}) \le target\_flops
\end{aligned}
\tag{1}
$$

其中，$L_i,H_i,W_i,C_i$分别表示模型缩放后的模型深度、输入长度、输入宽度和模型宽度。$w,d,r$则为对应于模型宽度、深度和分辨率的缩放系数。

作者采用了缩放比率系数$\phi$来统一模型的各个维度的缩放：

$$
\begin{aligned}
depth:\  & \ d=\alpha^\phi \\
width:\  & \ w=\beta^\phi \\
resolution:\  & \ r=\gamma^\phi \\
s.t.\  & \ \alpha\cdot\beta^2\cdot\gamma^2 \approx 2 \\
& \ \alpha \ge 1, \beta \ge 1, \gamma \ge 1 \\
\tag{2}
\end{aligned}
$$

其中，$\alpha,\beta,\gamma$为一个常数，可通过小型网格搜索确定。对于作者给出的约束条件$\alpha\cdot\beta^2\cdot\gamma^2\approx 2$，这里表示缩放后的模型大致会是原模型的浮点计算量的$2^\phi$左右，因为模型深度的两倍将扩大模型计算量的两倍，而模型宽度或分辨率的两倍将扩大计算量的四倍，即有模型计算量的扩大基数为$\alpha\cdot\beta^2\cdot\gamma^2$。

### Architecture

为了获得更好的效果，模型baseline也是十分重要的组成部分，作者采用了网络搜索的形式在限定的搜索空间中搜索到了EfficientNet-B0网络。搜索以$ACC(m)\times[FLOPS(m)/T]^w$为目标，其中$ACC(m)$表示模型的精度，$FLOPS(m)$表示模型的计算量，$T$为模型计算量的目标且$w=-0.07$为超参数来控制精度和计算量的平衡，这里采用计算量而不是模型的计算延迟作为评价目标是因为作者为了将模型与设备解藕，不同的设备进行运算其模型计算延迟会是不同的，而模型的计算量确实相同的。最后模型baseline如下：

![efficientnet baseline](https://raw.githubusercontent.com/simplestory/simplestory.github.io/master/img/2020-10-03/efficientnet_b0_baseline.png)

由图中可以看出其主要组成部分为MBConv和SE block。MBConv即为Mobilenetv2里面使用的inverted bottleneck，而SE block类似于注意力机制，一个轻便的模块，是对模型的一种优化。

从得到的baseline开始进行下面两步的缩放来得到最后的一系列分类模型：

- 首先固定$\phi=1$，假设有更多的可用资源，基于公式 1 和 2 对$\alpha,\beta,\gamma$进行小型的网格搜索。最后得到在约束条件$\alpha\cdot\beta^2\cdot\gamma^2\approx 2$下的最佳值$\alpha=1.2,\beta=1.1,\gamma=1.15$作为EfficientNet-B0模型的参数。
- 固定$\alpha,\beta,\gamma$，利用公式 3 使用不同的$\phi$进行缩放得到B1到B7模型。

至此，EfficientNet-B0到B7共八个模型已经建模完成。

## EfficientDet

为了获得精确快速的目标检测模型，作者基于单阶段检测算法提出了EfficientDet模型，主要解决了以下两个问题：

- 如何进行高效的多尺度特征融合，作者给出的答案是BiFPN
- 如何有效的进行模型缩放，作者这里应用了和EfficientNet一样的组合缩放方法

### BiFPN

多尺度特征融合的目的是汇总来自不同分辨率的特征是模型的泛化性能更好。FPN是一种有效的多尺度特征处理手段，它通过添加一条自顶向下的路线来获取其它分支的信息。但由于只有一条同路，其表达能力收到了限制，所以后面有提出了PANet，它在FPN的基础上添加了一条自低向上，再往后，研究人员通过网络搜索搜索出了NAS-FPN，它的表达能力要高于PANet，但其计算消耗巨大，并不适合于实际场景。最后，作者提出了BiFPN，具体结构如下：

![Bifpn](https://raw.githubusercontent.com/simplestory/simplestory.github.io/master/img/2020-10-03/bifpn.png)

BiFPN是在PANet的基础上改进的。首先，作者移除了PANet中只有单一输入的节点，这是为了简化模型，因为作者只有单一输入的节点并不需要进行特征融合，这在一个目的在于进行特征融合的结构上的贡献会比较小，将它去掉不会有太大的影响。其次，在结构的输入和输出节点之间额外添加了一条连接，这是为了更多的融合特征而无需添加太多的运算量。最后，与PANet只有一个自顶向下和自底向上的路径不同，作者重复使用了BiFPN，以允许模型提取出的高级特征进行融合。

在进行特征融合时，一般情况下是统一各个特征图的大小然后再进行相加，这意味这不同分辨率的特征图在融合时有着一样的权重，没有差别。然而作者观察到不同的分辨率对模型最后的输出贡献是不一样的，所以以同等重要性来对待不同分辨率的特征输入是不合适的。基于这种想法，作者考虑了三种加权的方法：

- Unbounded fusion: $O = \sum_i w_i\cdot I_i$，其中$w_i$是一个网络可学习权重，它可以是一个标量（针对每个特征进行加权）、一个向量（针对每个通道进行加权）或是一个张量（针对每个像素进行加权）。使用标量进行加权可以通过最小的计算量获得可观的精度提升，但标量权重可能会很大，也可能会很小，这会导致模型训练的不稳定。为此作者采取了权重归一化来界定各个权重的范围。
- Softmax-based fusion: $O = \sum_i\frac{e^{w_i}}{\sum_je^{w_j}}\cdot I_i$，这是采用Softmax方法来进行加权，这样权重的大小范围就固定在0到1之间，也能通过数值代表各自的重要性。但额外的Softmax计算耗时较长，为了减少耗时，作者提出了下面的加权方法。
- Fast normalized fusion: $O = \sum_i\frac{w_i}{\epsilon+\sum_jw_j}\cdot I_i$，其中$w_i \ge 0$在前面经过激活函数$Relu$之后可以得到保证。通过这种方法可以避免进行耗时的Softmax操作。

最后，BiFPN的组成如上图所示，由双向的跨尺度连接和加权特征融合组成。作者为了加快速度，还将特征融合部分的卷积更换为可分离卷积，同时在BiFPN添加了批量归一化并在每一个卷积计算后都进行激活函数计算。

**Note：** 这里要注意，BiFPN输入到输出的连接和输入到中间节点的连接所使用的输入节点是不一样的，只是值相同。具体可参考这篇[文章](https://zhuanlan.zhihu.com/p/129016081)。

最后EfficientDet的大致结构如下：

![efficientdet](https://raw.githubusercontent.com/simplestory/simplestory.github.io/master/img/2020-10-03/efficientdet.png)

### compound scaling

组合缩放采用了与EfficientNet类似的方法，只是对于目标检测模型，缩放的维度会比较多，这里作者使用了基于启发式的缩放方法，与之前一样采用$\phi$作为缩放尺度系数。

对于Backbone，作者使用了EfficientNet-B0到B6模型作为backbone。

BiFPN缩放。线性增加BiFPN的深度$D_{bifpn}$，而BiFPN的宽度$W_{bifpn}$则使用指数型的增加。之后作者通过在${1.2,1.25,1.3,1.35,1.4,1.45}$中进行网格搜索得到最佳的尺度缩放基数$1.35$，最后有下式进行缩放：

$$
\begin{aligned}
W_{bifpn} & = 64 \cdot 1.35^\phi \\
D_{bifpn} & = 3 + \phi
\tag{3}
\end{aligned}
$$

对于预测头部部分，将其宽度固定与BiFPN的宽度一致，即$W_{pred}=W_{bifpn}$，但线性增加它的深度：

$$
D_{box} = D_{class} = 3+\lfloor \phi/3\rfloor
$$

输入图像分辨率，因为模型特征第3到7层被用于BiFPN，所以输入的维度必须为$2^7=128$的倍数。使用线性增加如下：

$$
R_{input} = 512+\phi\cdot 128
$$

通过以上一系列的操作，我们可以得到EfficientDet-D0到D7共八个目标检测模型，对于EfficientDet-D6和D7，它们有相同的参数，除了分辨率参数不同。具体如下：

![efficientdet_d02d7](https://raw.githubusercontent.com/simplestory/simplestory.github.io/master/img/2020-10-03/efficientdet_d02d7.png)

## 致谢

本文主要参考了以下文章：

>[EfficientNet: Rethinking Model Scaling for Convolutional Neural Networks](https://arxiv.org/pdf/1905.11946.pdf)

>[EfficientDet: Scalable and Efficient Object Detection](https://arxiv.org/pdf/1911.09070.pdf)

>[全网第一SoTA成绩却朴实无华的pytorch版efficientdet](https://zhuanlan.zhihu.com/p/129016081)