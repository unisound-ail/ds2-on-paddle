#!/usr/bin/env python

import sys
import struct

def combine_feats_label(feats, label, feats_label):
    utt_label = dict()
    with open(label) as f:
        for line in f:
            parts = line.split()
            num_label = len(parts) - 1
            label_buf = struct.pack('<i%di' % num_label, num_label, *[int (s) for s in parts[1:]])
            utt_label[parts[0]] = label_buf
    const_tag = struct.pack('6c', *[chr(i) for i in (0x00, 0x42, 0x46, 0x4d, 0x20, 0x04)])
    with open(feats) as fin, open(feats_label, 'w') as fout:
        key = ''
        while True:
            key = ''
            while True:
                buf = fin.read(1)
                if buf == '' or buf == ' ':
                    break
                key = key + buf
            if buf == '':
                break
            key += ' '
            fout.write(key)
            buf = fin.read(15)
            assert buf[:6] == const_tag and buf[10] == chr(0x04)
            fout.write(buf)
            num_frame = struct.unpack('<i', buf[6:10])[0]
            dim = struct.unpack('<i', buf[11:15])[0]
            buf = fin.read(4 * dim * num_frame) # 4 is size of float
            fout.write(buf)
            fout.write(utt_label[key[:-1]])  # key[:-1] excludes the tailing whitespace

def main():
    if len(sys.argv) != 4:
        print >> sys.stderr, 'Usage: %s feats.ark label.txt feats_label.ark' % sys.argv[0]
        sys.exit(-1)
    combine_feats_label(sys.argv[1], sys.argv[2], sys.argv[3])

if __name__ == '__main__':
    main()
