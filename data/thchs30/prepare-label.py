#!/usr/bin/env python

import os
import re
import codecs
import operator

ws = re.compile(r'\s+')

utt_trans = dict()
char_to_int = dict()
blank_label = '.'  # we use whitespace as the label of blank in ctc

for trn in ('data/train/word.txt', 'data/dev/word.txt', 'data/test/word.txt'):
    with codecs.open(trn, 'r', 'utf-8') as f:
        for line in f:
            utt, trans = line.split(' ', 1)
            trans = re.sub(ws, '', trans)
            utt_trans[utt] = trans
            for c in trans:
                char_to_int[c] = 0
v = 1
for k in char_to_int.keys():
    char_to_int[k] = v
    v += 1
char_to_int[blank_label] = 0

with open('lex.txt', 'w') as flex:
    for k, v in sorted(char_to_int.items(), key=operator.itemgetter(1)):
        print >> flex, v, k.encode('utf8')

with open('label.txt', 'w') as flabel:
    for utt, trans in sorted(utt_trans.items()):
        print >> flabel, utt, ' '.join([str(char_to_int[c]) for c in trans])
