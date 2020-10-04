#! /usr/bin/awk -f

# Given a CIGAR string this script will calculate the length of the Reference sequence it aligns to.
#   will count matches, mismatches and deletes, from the cigar string. (Ignore I, N, P, S, H)
#
#  usage from a bash script >	# assign CIGAR string to bash variable 
#				cigarD="72S12M1D37M1D10M2D2M3D14M1D4M1D23M2D1M1I24M692S"  
					# call the awk script passing the bash variable to a awk variable using -v
					# read the output of the awk script into another bash variable (seqlengthRef) with bash "read var <<<"
#				read seqlengthRef <<< $(awk -v cigA="$cigarD" -f CigtoRefLen.awk)  

BEGIN {
# printf("\nyou passed me : %s\n",cigA)

regex =  "[[:upper:]]+";
n=split(cigA, arr, regex);   # arr will be array of numbers from CIGAR [72,12,1,37,1...]   # hmm need to check this? samtools should do some checking of sam file integrity? 
regex =  "[[:digit:]]+";
m=split(cigA, brr, regex);   # brr will be array of letters form CIGAR ["",S,M,D,M...]  will have empty letter in first position, from split function.
rlen=0
addPos=0   # flag to add current cigar value to length

for ( i=1; i<n; i++ ) {
         # print arr[i] ":" brr[i+1]
        len = arr[i]   

        switch( brr[i+1] ) {

        case "M" :      addPos = 1
                        break;
        case "=" :      addPos = 1
                        break;
        case "X" :      addPos = 1
                        break;
        case "D" :      addPos = 1
			break;
        case "I" : 	break;
        case "N" : 	break;
        case "P" : 	break;
        case "S" :	break;
        case "H" :      break;

        default:
                break;

        }


if ( addPos == 1 ) {
 rlen = rlen + len
 addPos = 0
 # print " adding: " arr[i] ":" brr[i+1] "  Running Total " rlen
 
}

}  # for loop

#print "reference length required (not including initial softclip) : " rlen
if ( rlen == 0 ) {
	print "*"
} else {
 print rlen
}

}
