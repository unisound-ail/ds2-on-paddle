#!/usr/bin/env bash
set -e

for x in train dev test; do
    mkdir -p paddle/$x
    i=1
    for ark in feats/$x/cmvn_fbank*.ark; do
        ./combine-ark-label.py $ark label.txt paddle/$x/feats-label.${i}.ark
        i=$((i+1))
    done
done

