# DS2 on Paddle 设计文档

## 目标

基于 [Paddle](http://www.paddlepaddle.org/) 实现 [Deep Speech 2 论文](https://arxiv.org/abs/1512.02595) 中描述的声学模型训练。语言模型和解码器部分另外实现。

## 计划

分两步实现，第一步实现原型，第二步调参、优化速度后完成大数据量的训练。

### 实现原型

目标：使用 Paddle 

训练数据：约 100 小时中文普通话提取的  filter bank 特征，短句，整句汉字标注。

模型结构：1 层 2-D Conv, 3 层 GRU, 1 层 FCN, 全部做 batch normalization.

优化准则：CTC

训练机器：单机多卡

工作：

* 准备训练数据
  * 将分别存储的 Kaldi 特征和 label 文件合并到一起，方便读取
* 补充 Paddle 中缺少的 layer 实现，如 row convolution
* 用 Python 实现训练流程
  * 编写网络配置文件
  * 编写 data provider
* 编写针对模型结构的 inference 代码，并与云知声解码器结合。

### 调参优化

目标： 在 Kubernetes 上使用多机多卡训练可用于线上部署的声学模型

训练数据：原始数据约一万小时，通过加加噪、调节语速和 pitch 等手段将数据训练数据扩充到数万小时

模型结构：1 层 2-D Conv, 7 层 GRU, 1 层 FCN, 全部做 batch normalization

优化准则：CTC

训练机器：多机多卡，Kubernetes

工作：

* 训练数据由预先提取的特征改为原始语音，将数据扩充（加噪等操作）和特征提取并入训练环节
* 训练加事
* 网络调参