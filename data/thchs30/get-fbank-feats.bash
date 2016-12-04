#!/usr/bin/env bash

cwd=`pwd`
orig=`pwd`/orig
featdir=`pwd`/feats
fbank_conf=conf/fbank.conf
train_cmd=cmd.sh
nj=8
export PATH=$PATH:`pwd`/bin:`pwd`/utils

. cmd.sh

set -x

#data preparation 
#generate text, wav.scp, utt2pk, spk2utt
steps/thchs-30_data_prep.sh $cwd $orig/data_thchs30

for x in train dev test; do
   #make  mfcc 
   steps/make_fbank.sh --compress false --fbank-config "$fbank_conf" --nj $nj \
       --cmd "$train_cmd" data/$x exp/make_fbank/$x $featdir/$x || exit 1;
   #compute cmvn
   steps/compute_cmvn_stats.sh data/$x exp/make_fbank/$x $featdir/$x || exit 1;
   # apply cmvn
   steps/apply_cmvn.sh --nj $nj data/$x exp/make_fbank/$x $featdir/$x || exit 1;
done
