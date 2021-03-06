---
layout:     post
title:      "LightGBM模型"
subtitle:   "A Highly Efficient Gradient Boosting Decision Tree" 
date:       2019-03-24
author:     "Simplestory"
header-style: text
catalog: False
mathjax: true
tags:
    - Machine Learning
---

>上文提到了一个高效的树集成算法[Xgboost模型](https://simplestory.github.io/2019/03/17/Xgboost/)，但是在处理特征维度和数据量较大的数据时，效率仍然是低迷的。相比于GBDT和Xgboost等模型，微软开源的Lightgbm模型采用了各种手段来降低数据量和数据特征维度，从而大大提高了模型的训练速度也确保了准确率。

## How to do

为了降低因大量的实例数和较高的特征维度对模型训练的影响，一个自然的想法就是减少数据实例数和特征维度。而Lightgbm模型采取的方案分别为：Gradient-based One-Side Sampling(GOSS)和Exclusive Feature Bundling(EFB)。

## GOSS

这其实是一种采样方法。微软在实验中发现如果一个实例有着较小的梯度，那么它对模型训练的贡献也校少，因为小梯度意味着这个样本已经训练完全。GOSS通过保存大梯度样本，随机选取小梯度样本，并为其弥补上一个常数权重。这样，GOSS更关注训练不足的样本，同时也不会过多地改变原始分布。相关算法如下：

![Gradient-based One-Side Sampling](/img/in_posts/20190324/Lightgbm_goss.png)

具体操作是GOSS首先根据样本梯度的绝对值来排序（从大到小），并选取前面的$a \times 100\%$个样本。然后随机从剩下的样本中选取$b \times 100\%$个样本。再之后，GOSS对每个小梯度样本通过一个常数权重（通常为$\frac{1-a}{b}$）来放大。

## EFB

接下来就是降低特征维度的问题了。其实我们可以发现具有高维度特征的数据通常都是离散的，而且在离散的特征空间中，许多特征都是相互独立的，所以我们可以将这些独立的特征捆绑在一起作为一个单独的特征。具体算法如下：

![Greedy Bunding](/img/in_posts/20190324/Lightgbm_greedy.png)

首先我们建立一张带权图，其中的边的权值表示连接的两个特征之间的冲突量（即不相互独立的程度）。然后按照度对特征进行降序排序。最后遍历排序后的特征序列，检查特征是否能加入已有的捆绑中（由冲突量确定），否则新建一个捆绑。

上面这种做法的确有效，但在大特征量的情况下依然不尽人意。我们可以根据特征的非零值对特征进行排序从而得到特征序列，这样就不用去创建特征图了。

以上已将特征放在捆绑中，接下来就是合并同一捆绑中的特征。这一步的关键在于原始特征值可以从捆绑中区分出来。因为基于直方图的算法存储离散的条形而不是连续的特征值。这一点可以通过偏移量来实现。具体如下：

![Merge Exclusive Features](/img/in_posts/20190324/Lightgbm_merge.png)

**详细的数学推导见下方论文**

## 致谢

>[LightGBM: A Highly Efficient Gradient Boosting Decision Tree](http://120.52.51.13/papers.nips.cc/paper/6907-lightgbm-a-highly-efficient-gradient-boosting-decision-tree.pdf)