# DS2 on Paddle 设计文档

## 目标

基于 [Paddle](http://www.paddlepaddle.org/) 实现 [Deep Speech 2 论文](https://arxiv.org/abs/1512.02595) 中描述的声学模型训练。语言模型和解码器部分另外实现。

## 计划

分两步实现，第一步实现原型，第二步调参、优化速度后完成大数据量的训练。

### 实现原型

目标：使用 Paddle 搭建一个训练 DS2 的声学模型的完整流程

训练数据：约 100 小时中文普通话提取的 filter bank 特征， 训练语音为短句，有整句的汉字标注

模型结构：1 层 2-D Conv, 3 层 RNN (GRU/LSTM 都实现), 1 层 FCN, batch normalization

优化准则：CTC

训练机器：单机多卡

工作：

* 准备训练数据
  * 复用 Kaldi 的特征存储格式，为了避免 feature 和 label 分开存放导致的训练时查找 label 带来的效率问题，先预处理一下，使每条语音的 feature 和 label 在相同的文件里连续存放
* 补充 Paddle 中缺少的 layer 实现，如 row convolution
  * 先确认新增 layer 是否必须在 Paddle 的代码树里添加文件，能否将实现分开
* 用 Python 实现训练流程
  * 编写训练配置文件，包括描述网络结构、选择优化算法、配置训练参数等
  * 编写 data provider
* 编写针对 DS2 模型结构的 inference 代码，并与云知声解码器结合

### 调参优化

目标： 在 Kubernetes 上使用多机多卡训练可用于线上部署的声学模型

训练数据：原始数据约一万小时，通过加加噪、调节语速和 pitch 等手段将训练数据扩充到数万小时

模型结构：1 层 2-D Conv, 7 层 RNN (GRU/LSTM 对比), 1 层 FCN, batch normalization

优化准则：CTC

训练机器：多机多卡，Kubernetes

工作：

* 训练数据由预先提取的特征改为原始语音，将数据扩充（加噪等操作）和特征提取并入训练环节
* 实现基于 Kubernetes 的多机多卡训练
* 训练加速
* 网络调参优化
