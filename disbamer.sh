#!/bin/sh

# - D - I - S - B - A - M - E - R - 
#
# Display an aligned read sequence in a bam file alongside its reference sequence, showing inserts, deletes and mismatches.
#
# for best results pipe to less -S?

# Requires: SAMTOOLS 
# the line number of the read to display in the bam file. (ie: samtools view file.bam | less -S   then use -N to see line numbers, or use grep sed etc...)
# the first read is line 1, second read is line 2 etc..
# Setup :
# 1. soft link in current directory to your sam/bam file. named sam.lnk
#	configure: > ln -s /path/to/sam/bam/file.bam sam.lnk
# 2. soft link to the reference file associated with the sam/bam file (regions [chromosome name] must match from SAM file to Ref file.)
# 	configure: > ln -s /path/to/reference/file.fna ref.lnk
# RUN : 
#      bash disbamer 4 | less -S
# 4 = fourth read in bam file, on the fourth line.
#
#

# COMMENT: if no args display message to stderr ">&2"
if [[ $# -ne 1 ]]; then
    echo "------ Usage: bash disbamer.sh 2  (2 is the line of read number) " >&2
    echo "------ Display a read from a bam file along with associated reference sequence.	" >&2
    echo "------ disbamer will call 'samtools view' on a sam file defined by soft link to 'sam.lnk' and display a read.  "  >&2
    echo  ------ Then it will look up reference \(via ref.lnk\) and display reference sequence for read from sam file.  >&2
    exit 2
fi

echo ">>> Running disbamer for read $1 " >&2
echo ------ Calling samtools view for file $(basename $(readlink sam.lnk)) to display read in line :  $1
echo bam path: $(readlink sam.lnk)
echo ref path: $(readlink ref.lnk)

# COMMENT: check samtools loaded!
command -v samtools >/dev/null 2>&1 || { echo >&2 "------ Is samtools loaded? error running samtools, exiting."; exit 1; }

echo ---------R-E-A-D----B-A-M------------ "(samtools sam.lnk)"
bamdata=`samtools view sam.lnk | sed "${1}q;d"`
# echo "$bamdata"
# echo -------------------------------------
read readD <<< $(echo "$bamdata" | awk '{print $1}')
echo read "$readD"
read flagD <<< $(echo "$bamdata" | awk '{print $2}')
echo flag "$flagD"

read regionD <<< $(echo "$bamdata" | awk '{print $3}')
echo region "$regionD"
read positionD <<< $(echo "$bamdata" | awk '{print $4}')
echo position "$positionD"

read qualityD <<< $(echo "$bamdata" | awk '{print $5}')
echo quality "$qualityD"

read cigarD <<< $(echo "$bamdata" | awk '{print $6}')
echo cigar "$cigarD"
read seqD <<< $(echo "$bamdata" | awk '{print $10}')
echo sequence ${seqD:1:50} "...."   # substring
# echo "check_"$seqD"_check"
if [ "$seqD" == "*" ]
then
  echo "No sequence data present, supplementary or secondary alignments in bam do not show bases."
  echo " check data,  exiting......"
  echo -------------------------------------
  exit 1
fi

# need length of reference to extract - from cigar?
read seqlengthD <<< $(awk -v cigA="$cigarD" -f cigtoRefLen.awk)
echo ---------l-e-n-g-t-h----------------- "(cigtoRefLen.awk)"
echo matching reference length required : "$seqlengthD"
if [ "$seqlengthD" == "*" ]
then
  echo "CIGAR STRING error, 0 length sequence."
  echo " check data,  exiting......"
  echo -------------------------------------
  exit 1
fi

echo ---------r-e-f-e-r-e-n-c-e----------- "(getrefseq.awk ref.lnk)"
echo Please Wait! getting matching reference:  "----may take some time....."
read seqrefD <<< $(awk -v regA="$regionD" -v posA="$positionD" -v lenA="$seqlengthD" -f getrefseq.awk ref.lnk)
if [ "$seqrefD" == "" ]
then
  echo "REFERENCE NOT FOUND. ."
  echo " please check data and reference link,  exiting......"
  echo -------------------------------------
  exit 1
fi

echo
echo ---------g-e-n-o-m-i-c---v-i-e-w----- "(viewread.awk)"
awk -v cigA="$cigarD" -v seqA="$seqD" -v refA="$seqrefD" -f viewread.awk

