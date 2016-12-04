# ds2-on-paddle

Implementation of Baidu's Deep Speech 2 using Paddle as the framework for training AM

## Instructions

### Prepare data

We use THCHS30 as the training data to test the prototype implementation.

#### Download data and get the filter bank features with CMVN applied

```bash
$ cd data/thchs30
$ ./download.bash
$ ./get-fbank-feats.bash
$ cd ../..
```
#### Generate data for Paddle's use

The output would be placed in data/thchs30/paddle

```bash
$ cd data/thchs30
$ ./prepare-label.py
$ ./generate-data-for-paddle.bash
$ cd ../..
```
