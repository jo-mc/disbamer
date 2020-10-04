#! /usr/bin/awk -f

# Given a CIGAR region position and length this script will extract the corresponding sequence from a Reference.
#   will count matches, mismatches and deletes, from the cigar string. (Ignore I, N, P, S, H)
#
#  usage from a bash script >   # assign region, position and length to string to bash variables (cigtoRefLen.awk will calculate length required from a  cigar string)
#                               awk -v regA="$regionD" -v posA="$positionD" -v lenA="$seqlengthD" getrefseq.awk lnkref
                                        # call the awk script passing the bash variables as above
					# Not eneeds the link to the reference!
                                        # read the output of the awk script into another bash variable (seqlengthRef) with bash "read var <<<"
#                               read seqrefD <<< $(awk command above)
#                               example region and position: region = "CM000668.2" region = "chr6" position = 62656  
# NOTE: will need the region in the SAM/BAM to match region in the reference!! (ie chromosome name, this should be the case if you aligned to the reference! 
#                                                                                  otherwise you will need to rename - possible addition to this utility is the name conversion? )  
# Search output goes to /dev/stderr (it will initially display in "less" but will dissapear, once move cursor. If redirecting disbamer to file search output will show on screen.

# find read reference alignment sequence

BEGIN {
# ::::Get Data Passed from disbamer::::
region = regA
position = posA
seqlenreq = lenA

to_pos = position + seqlenreq
aregion = 0   # found region?
aSeq = ""
aPos = 0
stage = 1
printf("search regions: ")  > "/dev/stderr" 
regCnt = 1
}

{

switch (stage) {
        case "1" : # find region
                if ( index( $1, region ))
                        { stage = "2"
                          # print region, stage
                        }
		if ( index( $1, ">" )) 
			{
                            printf(".R%s",regCnt)   > "/dev/stderr"  # region, stage. output to std error as print will default back to shell script.
			   # printf(".R%s ref region:%s  search region: %s \n ",regCnt,$1, region)   > "/dev/stderr"
                           regCnt = regCnt + 1
			}
                break
        case "2" : # find start
                # print aPos, position
                if ((aPos + length($0)) >= position) {
                        aSeq = substr($0,(position - aPos), (length($0) - (position - aPos) + 1)) 
                        stage = 3
                          # printf(" found start %s, aPos %s, aSeq: %s, len %s, \n ref: %s \n",position,aPos,aSeq,length(aSeq),$0) > "/dev/stderr"
                }
                aPos = aPos + length($0)
                break
        case "3" : # find end
                # print "3", aPos
                if ((aPos + length($0)) >= (to_pos)) {
                          # print " last aSeq b4 final append " aSeq, length(aSeq), " to_pos " to_pos, "aPos", aPos # test
                       aSeq = aSeq substr($0,1,(to_pos - aPos + 1)) 
                       stage =  4
                } else {
			# print " refseq: " aSeq, length(aSeq)  # test
                        aSeq = aSeq $0    # append current seq data to aSeq.
                        aPos = aPos + length($0)
                }
                break
        case "4" : # OUPUT print the required referecne string to stdout, calling bash script uses read to collect.
		   printf("\n%s\n",aSeq)
                   # print " length " length(aSeq), aPos
                 exit 1
                break
        default : print "what? region not found...."
		break
}


}

END {
switch (stage) {
case "1" :
	printf("\n XXXX Could not find region: %s in lnk.ref, link to your reference. \n",$1)   > "/dev/stderr"
	break;
case "2" :
        printf("\n XXXX Could not find start postion: %s in region %s for lnk.ref, link to your reference. \n",position, $1)   > "/dev/stderr"
        break;
case "3" :
        printf("\n XXXX Could not find end position: %s in region %s for lnk.ref, link to your reference. \n",to_pos,$1)   > "/dev/stderr"
        break;
case "4" : # OK
       #  printf("\n Found region and position in reference. \n",$1)   > "/dev/stderr"
	printf("\n") > "/dev/stderr" 
        break;
default : break
}
}
