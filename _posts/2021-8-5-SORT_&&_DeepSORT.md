---
layout:     post
title:      "SORT && DeepSORT"
subtitle:
date:       2021-08-05
author:     "Simplestory"
header-style: text
catalog: False
mathjax: true
tags:
    - Deep Learning
---

> 当前工业界常用的多目标跟踪框架。

## SORT

该算法基于目标检测网络（Faster Rcnn），并利用卡尔曼滤波和匈牙利算法（或KM算法），极大地提高了多目标跟踪的速度。大致流程如下：

![SORT.png](/img/in_posts/20210805/SORT.png)

目标检测算法获得当前帧的目标框Detections，卡尔曼滤波获得当前帧的轨迹Tracks，对Detections和Tracks进行IOU匹配，最终结果分为三类：

- Unmatched Tracks：即Tracks部分失配，如果失配持续了$T_{lost}$次，则将该目标删除。
- Unmatched Detections：即Detections部分失配，需要为该Detection分配一个新的Track。
- matched Tracks：这部分说明已经匹配上了，利用这部分对卡尔曼滤波进行更新。

卡尔曼滤波可以根据Tracks的状态来预测下一帧的目标框状态，更新是根据观测值（匹配上的Track）和估计值更新所有Tracks的状态。

## DeepSORT

相比SORT，DeepSORT通过集成表观信息并使用级联匹配来提升SORT的表现。这样模型能够更好地处理目标被长时间遮挡的情况，很大程度地降低了ID switch指标测试值。表观信息也就是目标对应的特征，论文中通过在大型行人重识别数据集上训练得到的深度关联度量来提取表观特征(借用了ReID领域的模型)。整体流程大致如下：

![DeepSORT.png](/img/in_posts/20210805/DeepSORT.png)

每个轨迹都会维护一个变量$h$用于记录当前帧与上一次匹配成功帧的差值，在轨迹与detections匹配时$h$置为0。当$h$大于事先设定的阈值$A_{max}$时，则认为该轨迹终止（即长时间匹配不上的轨迹认为已经结束了）。对于没有匹配成功的detections，有可能是新轨迹，也有可能是误检测。论文里设置了一个Unconfirmed状态来辨别，当连续$n\_init$帧（论文设置为3）该轨迹都能成功匹配则将该轨迹状态更改为Confirmed，否则删除该轨迹。各状态的转移如下：

![status.png](./img/in_posts/20210805/status.png)

匹配上，算法采用了表观模型和运动模型来计算相似度得到代价矩阵，同时使用门控矩阵来限制代价矩阵中过大的值。

运动模型使用detection和track的马氏距离的平方来刻画运动匹配程度：

$$
\begin{aligned}
d^{(1)}(i,j) &= (d_j-y_i)^TS_i^{-1}(d_j-y_i) \\
b^{(1)}_{i,j} &= I[d^{(1)}(i,j) \le t^{(1)}]
\end{aligned}
$$

其中$d_j$表示第$j$个detection，$y_i$表示第$i$个track，$S_i^{-1}$代表$d$和$y$的协方差。$b_{i,j}^{(1)}$为指示器，使用卡方分布的0.95分位点（$t^{(1)}=9.4877$）作为阈值，小于该阈值则匹配成功。

---
**马氏距离（Mahalanobis Distance）：**

马氏距离表示数据的协方差距离，是一种有效的计算两个未知样本集的相似度的方法。与欧氏距离不同的是它考虑到数据各种特性之间的联系。

对一个均值为$\mu=(\mu_1,\mu_2,\dots,\mu_p)^T$，协方差矩阵为$\Sigma$的多变量向量$x=(x_1,x_2,\dots,x_p)^T$，其马氏距离为：

$$
D_M(x) = \sqrt{(x-\mu)^T\Sigma^{-1}(x-\mu)}
$$

协方差矩阵为方阵，维度与样本维度一致。

---

表观模型采用余弦距离来度量表观特征之间的距离（由模型提取出一个特征向量，使用余弦距离来进行比对）：

$$
\begin{aligned}
d^{(2)}(i,j) &= min\{1-r_j^Tr_k^{(i)}\vert r_k^{(i)}\in R_i\} \\
b^{(2)}_{i,j} &= I[d^{(2)}(i,j) \le t^{(2)}]
\end{aligned}
$$

其中$r_j^Tr_k^{(i)}$计算的是余弦相似度（余弦距离=1-余弦相似度）。SORT中仅仅用运动信息进行匹配会导致ID Switch比较严重，引入表观模型以及级联匹配可以缓解这个问题。$b_{i,j}^{(2)}$为指示器，余弦距离小于阈值则认为匹配，该阈值属于超参数（论文中设为0.2）。由于轨迹太长会导致表观产生变化，继续使用这种最小余弦距离作为度量就有风险，所以论文中只对轨迹的最新的$L_k=100$之内detections进行计算最小余弦距离。

综合匹配度是由运动模型和表观模型加权得到的：

$$
c_{i,j} = \lambda d^{(1)}(i,j)+(1-\lambda)d^{(2)}(i,j) \tag{5}
$$

$\lambda$是一个超参数，作者考虑到摄像头会有移动所以将其设置为0。

门控矩阵计算如下：

$$
b_{i,j} = \prod_{m=1}^2b^{(m)}_{i,j} \tag{6}
$$

$b_{i,j}$也为指示器，当$b_{i,j}=1$的时候才会被初步匹配。

为了解决目标被长时间遮挡，DeepSORT提出的另一个方法是级联匹配。当一条轨迹被遮挡了较长时间，卡尔曼滤波器连续预测无法得到更新。这种情况会导致在两个轨迹竞争同一个detection时，遮挡时间较长的轨迹往往匹配得到的马氏距离更小，使得detection更可能和遮挡时间较长的轨迹匹配，干扰了轨迹的持续性。所以使用级联匹配来让每次匹配时考虑的都是遮挡时间相同的轨迹，同时遮挡时间较少的轨迹优先考虑。算法大致如下：

![matching_cascade.png](/img/in_posts/20210805/matching_cascade.png)

在匹配的最后阶段还对Unconfirmed和age=1的未匹配轨迹进行基于IOU的匹配。这可以缓解因为表观突变或者部分遮挡导致的较大变化。

表观特征这部分借用了行人重识别领域的网络模型，这部分的网络是需要提前离线学习好，独立于目标检测和跟踪器模块，功能是提取对应bounding box中的feature，得到一个固定维度的embedding作为该bbox的代表，供计算相似度时使用。论文中用的是wide residual network, 具体结构如下：

![wide_residual_net.png](/img/in_posts/20210805/wide_residual_net.png)

## 致谢

> [SIMPLE ONLINE AND REALTIME TRACKING](https://arxiv.org/pdf/1602.00763v2.pdf)
> 
> [SIMPLE ONLINE AND REALTIME TRACKING WITH A DEEP ASSOCIATION METRIC](https://arxiv.org/pdf/1703.07402.pdf)
> 
> [Deep SORT多目标跟踪算法代码解析](https://www.cnblogs.com/pprp/articles/12736831.html)