---
layout:     post
title:      "线性回归和Logistic回归"
subtitle:   
date:       2018-08-13
author:     "Simplestory"
header-img: img/post_bg_debug.png
header-mask: 0.3
catalog: true
mathjax: true
tags:
    - Machine Learning
---

>好久没更博客了，停了大半年，也看了大半年的机器学习和深度学习方面的书籍，现在是时候输出一下了

# 线性回归

给定数据集$D=\\{(\mathbf{x_1},y_1),(\mathbf{x_2},y_2),...,(\mathbf{x_m},y_m)\\}$，其中$\mathbf{x_i}=(x_{i1};x_{i2};...;x_{id}), \ y_{i} \in R$. 线性回归试图学得一个线性模型

$$f(x_i)=wx_i+b$$

使得$f(x_i)\simeq y_i$.

## 推导过程

考虑使用MSE（均方差误差）来衡量模型好坏，则有损失函数$L(w,b)$:

$$
\begin{aligned}
L(w,b) & =\sum_{i=1}^m (f(x_i)-y_i)^2  \\
& =\sum_{i-1}^m (y_i-wx_i-b)^2
\end{aligned}
$$

目标函数为：

$$
\begin{aligned}
(w^*,b^*) & =argmin_{(w,b)} L(w,b)  \\
& =argmin_{(w,b)} \sum_{i=1}^m (y_i-w_i-b)^2
\end{aligned}
$$

将$L(w,b)$分别对$w,b$求偏导，并令导数为零联立可求解

$$
\begin{cases}
\nabla_w L(w,b) = 2(w\sum_{i=1}^m x_i^2 -\sum_{i=1}^m (y_i-b)x_i )=0 \\
\nabla_n L(w,b) = a(mb-\sum_{i=1}^m (y_i-wx_i))=0
\end{cases}
$$

求解可得$w,b$的最优闭式解：

$$w=\frac{\sum_{i=1}^m y_i(x_i-\overline{x})}{\sum_{i=1}^m x_i^2 - \frac{1}{m}(\sum_{i=1}^m x_i)^2}$$

$$b=\frac{1}{m}\sum_{i=1}^m (y_i-wx_i)$$

其中$\overline{x}=\frac{1}{m} \sum_{i=1}^m x_i$为$x$的均值

## Scikit-learn应用

具体API参考Scikit-learn官网：
[sklearn.linear_model.LinearRegression](http://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LinearRegression.html)

# Logistic回归

**这是一种分类方法**

Logistic分布：

设X是连续随机变量，$\mathbf{X}$服从逻辑斯蒂分布是指$\mathbf{X}$具有下列分布函数和密度函数：

$$
\begin{cases}
F(x)=P(X \leq x)=\frac{1}{1+e^{-(x-\mu)/\gamma}} \\
f(x)=F\prime(x)=\frac{e^{-(x-\mu)/\gamma}}{\gamma(1+e^(x-\mu)/\gamma)^2}
\end{cases}
$$

式中$\mu$为位置参数，$\gamma > 0$为形状参数

二项逻辑斯蒂回归模型是如下的条件概率：

$$P(Y=1|x)=\frac{exp(w\cdot x+b)}{1+exp(w\cdot x+b)}$$

$$P(Y=0|x)=\frac{1}{1+exp(w\cdot x+b)}$$

这里$x\in R^n$是输入，$Y\in \\{0,1\\}$是输出，$w\in R^n$为权值向量，$b\in R$为偏置，$w\cdot x$为內积.

为了表达方便，将w,b进行合并可得：

$$P(Y=1|x)=\frac{exp(w\cdot x)}{1+exp(w\cdot x)}$$

$$P(Y=0|x)=\frac{1}{1+exp(w\cdot x)}$$

由前面这些假设和推论可得，逻辑斯蒂回归模型返回的是样本为正例的概率, 即$P(Y=1\vert x)$

## 推导过程

由极大似然函数有损失函数$L(w)$:

$$L(w)=\prod_{i=1}^N P(Y=1|x_i)^{y_i}[1-P(Y=0|x_i)]^{1-y_i}$$

为防止因连乘而导致溢出，取对数可得：

$$L(w)=\sum_{i=1}^N [y_i\log{P(Y=1|x_i)}+(1-y_i)\log{1-P(Y=0|x_i)}]$$

化简可得：

$$L(w)=\sum_{i=1}^N [y_i(w\cdot x_i)-\log{(1+exp(w\cdot x_i))}]$$

对$L(w)$求极大值，得到w的估计值。通常采用梯度下降法和拟牛顿法求解

## Scikit-learn应用

[sklearn.linear_model.LogistRegression](http://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LogisticRegression.html)

## 致谢

> 周志华的西瓜书，李航的统计学习方法