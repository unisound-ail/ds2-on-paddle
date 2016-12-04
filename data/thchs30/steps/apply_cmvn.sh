#!/bin/bash

# Begin configuration section.
nj=4
cmd=run.pl
cmvn_opts="--norm-vars=true"
# End configuration section.

echo "$0 $@"  # Print the command line for logging

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
   echo "Usage: $0 [options] <data-dir> [<log-dir> [<fbank-dir>] ]";
   echo "e.g.: $0 data/train exp/apply_cmvn/train fbank"
   echo "Note: <log-dir> defaults to <data-dir>/log, and <fbank-dir> defaults to <data-dir>/data"
   echo "Options: "
   echo "  --nj <nj>                                        # number of parallel jobs"
   echo "  --cmd (utils/run.pl|utils/queue.pl <queue opts>) # how to run jobs."
   exit 1;
fi

data=$1
if [ $# -ge 2 ]; then
  logdir=$2
else
  logdir=$data/log
fi
if [ $# -ge 3 ]; then
  fbankdir=$3
else
  fbankdir=$data/data
fi


# make $fbankdir an absolute pathname.
fbankdir=`perl -e '($dir,$pwd)= @ARGV; if($dir!~m:^/:) { $dir = "$pwd/$dir"; } print $dir; ' $fbankdir ${PWD}`

# use "name" as part of name of the archive.
name=`basename $data`

mkdir -p $fbankdir || exit 1;
mkdir -p $logdir || exit 1;

scp=$data/feats.scp

required="$scp"

for f in $required; do
  if [ ! -f $f ]; then
    echo "apply_cmvn.sh: no such file $f"
    exit 1;
  fi
done

split_scps=""
for n in $(seq $nj); do
    split_scps="$split_scps $logdir/feats.$n.scp"
done

utils/split_scp.pl $scp $split_scps || exit 1;

$cmd JOB=1:$nj $logdir/apply_cmvn_${name}.JOB.log \
    apply-cmvn $cmvn_opts --utt2spk=ark:$data/utt2spk scp:$data/cmvn.scp scp:$logdir/feats.JOB.scp \
    ark,scp:$fbankdir/cmvn_fbank_$name.JOB.ark,$fbankdir/cmvn_fbank_$name.JOB.scp \
    || exit 1;

if [ -f $logdir/.error.$name ]; then
  echo "Error producing fbank features for $name:"
  tail $logdir/apply_cmvn_${name}.1.log
  exit 1;
fi

# concatenate the .scp files together.
for n in $(seq $nj); do
  cat $fbankdir/cmvn_fbank_$name.$n.scp || exit 1;
done > $data/feats_cmvn_applied.scp

rm $logdir/feats.*.scp  $logdir/segments.* 2>/dev/null

nf=`cat $data/feats_cmvn_applied.scp | wc -l`
nu=`cat $data/utt2spk | wc -l`
if [ $nf -ne $nu ]; then
  echo "It seems not all of the feature files were successfully ($nf != $nu);"
  echo "consider using utils/fix_data_dir.sh $data"
fi

echo "Succeeded applying cmvn to filterbank features for $name"

