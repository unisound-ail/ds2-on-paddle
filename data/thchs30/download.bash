#!/usr/bin/env bash

set -e

for f in data_thchs30.tgz test-noise.tgz resource.tgz; do
    wget -P orig -c http://www.openslr.org/resources/18/$f && tar -C orig -xzf orig/$f
done
