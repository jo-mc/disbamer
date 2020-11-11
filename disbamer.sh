#!/bin/sh


# - D - I - S - B - A - M - E - R - 
#
# Display an aligned read sequence in a bam file alongside its reference sequence, showing inserts, deletes and mismatches.
#
# for best results pipe to less -S, if not will wrap sequence output 80 bp per line.


if [ -t 1 ] ; then nopipe_out=terminal;  fi;  # if output is not piped
# nopipe_out will be set to terminal if the script output is not being sent to a pipe.
# This means the output will go to the terminal and I need to be aware of line wrapping wrapping. (handled in viewread.awk)
# if flag '-t' = 1 then output is going to terminal:
# https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html


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
    echo " disbamer: display fastq read against reference:" >&2
    echo  " "
    echo -e "------ Usage: \"bash disbamer.sh 2 | less -S\"  (\"2\" is the line of read number to display against a reference) " >&2
    echo "------"	
    echo " Requires: samtools to be loaded. less -S to show read without wrapping - use arrow keys to scroll horizontally." >&2
    echo "------ Display a read from a bam file along with associated reference sequence.	" >&2
    echo "------ disbamer will call 'samtools view' on a sam file defined by soft link to 'sam.lnk' and display a read.  "  >&2
    echo  ------ Then it will look up reference \(via ref.lnk\) and display reference sequence for read from sam file.  >&2
    exit 2
fi

echo ">>> Running disbamer for read $1 " >&2
echo ------ Calling samtools view for file "$(basename "$(readlink sam.lnk)")" to display read in line :  $1
echo bam path: "$(readlink sam.lnk)"
echo ref path: "$(readlink ref.lnk)"


# COMMENT: check samtools loaded!
command -v samtools >/dev/null 2>&1 || { echo >&2 "------ Is samtools loaded? error running samtools, exiting."; exit 1; }

echo ---------R-E-A-D----B-A-M------------ "(samtools sam.lnk)"
bamdata=$(samtools view sam.lnk | sed "${1}q;d")
# echo "$bamdata"
# echo -------------------------------------
read -r readD <<< "$(echo "$bamdata" | awk '{print $1}')"
echo read "$readD"
read -r flagD <<< "$(echo "$bamdata" | awk '{print $2}')"
echo flag "$flagD"

read -r regionD <<< "$(echo "$bamdata" | awk '{print $3}')"
echo region "$regionD"
read -r positionD <<< "$(echo "$bamdata" | awk '{print $4}')"
echo position "$positionD"

read -r qualityD <<< "$(echo "$bamdata" | awk '{print $5}')"
echo quality "$qualityD"

read -r cigarD <<< "$(echo "$bamdata" | awk '{print $6}')"
ciglen="${#cigarD}"
echo cigar "   |- ${ciglen} -| : " "${cigarD:0:50}" "...." "${cigarD:$(($ciglen-20)):20}."   # cigar
read -r seqD <<< "$(echo "$bamdata" | awk '{print $10}')"
echo sequence "|- ${#seqD} -| : " "${seqD:0:50}" ".... " "${seqD:$((${#seqD}-20)):20}."  # ${::} substring ${#} length of string var
# echo "check_"$seqD"_check"
if [ "$seqD" == "*" ]
then
  echo "No sequence data present, secondary alignments in bam do not show bases."
  echo " check data,  exiting......"
  echo -------------------------------------
  exit 1
fi

# need length of reference to extract - from cigar?
read -r seqlengthD <<< "$(awk -v cigA="$cigarD" -f cigtoRefLen.awk)"
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
read -r seqrefD <<< $(awk -v regA="$regionD" -v posA="$positionD" -v lenA="$seqlengthD" -f getrefseq.awk ref.lnk)
if [ "$seqrefD" == "" ]
then
  echo "REFERENCE NOT FOUND. ."
  echo " please check data and reference link,  exiting......"
  echo -------------------------------------
  exit 1
fi

echo
echo ---------g-e-n-o-m-i-c---v-i-e-w----- "(xviewread.awk) note 'x' test"
awk -v cigA="$cigarD" -v seqA="$seqD" -v refA="$seqrefD" -v outview="$nopipe_out" -f viewread.awk

