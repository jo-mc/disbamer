
#! /usr/bin/awk -f 

# Given a read sequence, cigar string and reference sequences, print out the alignment.
#
#  usage from a bash script >   # assign read sequence, cigar string and reference sequences, to awk variables from a bash script, and call awk script:
#                               awk -v cigA="$cigarD" -v seqA="$seqD" -v refA="$seqrefD" outview="$nopipe_out" -f viewread.awk
                                        # call the awk script passing the bash variables as above
# Displays The read sequence with '-' for deletes 'N' quoted base(s) for insert(s); then the reference sequence on the next line, followed by the read position on subsequenct lines.
# Pipe display to less -S to allow scrolling horizontally.. 
# a line wrapping enhancment is under consideration....


BEGIN {     

# :::from disbamer:::
cig = cigA
seq = seqA
ref = refA
# output summary of input data:
# print "Cigar: ", cig  # $6
# print "Seq read: ", substr(seqA,1,50), "...."   # $10
# print " Seq ref: ",  substr(refA,1,50), "...."

# initialise data
regex =  "[[:upper:]=]+";   # '=' as it is a cigar term
n=split(cig, arr, regex);
regex =  "[[:digit:]]+";
m=split(cig, brr, regex);
pos=1
read_seq= ""
softClip = ""
hardClip = ""
totalClip = 0
startsoftclip = 1
inserts = 0
deletes = 0
matches = 0
rlen = 1
addPos = 0
addIns = 0

kStr = ""
kspace = " "  # space to align read position to first multiple of 10 after any clip

for ( i=1; i<n; i++ ) {
#	 print arr[i] "--------" brr[i+1]
	len = arr[i]

	switch( brr[i+1] ) {
	
	case "M" : read_seq = read_seq substr(seq,pos,len)
			pos = pos + len
			addPos = 1
			matches = matches + len
			break
        case "=" : read_seq = read_seq substr(seq,pos,len)
                        pos = pos + len
                        addPos = 1
			matches = matches + len
                        break
        case "X" : read_seq = read_seq substr(seq,pos,len)
                        pos = pos + len
                        addPos = 1
                        break
	case "D" : for(c=0;c<len;c++) read_seq = read_seq "-"
                        addPos = 1
			deletes = deletes + len
			break
        case "I" : read_seq = read_seq "'" substr(seq,pos,len) "'"
                        pos = pos + len
			addIns = 1
			inserts = inserts + len
                        break
        case "N" : for(c=0;c<len;c++) read_seq = read_seq "N"
                        pos = pos + len
                        break
        case "P" : for(c=0;c<len;c++) read_seq = read_seq "P"
                        pos = pos + len
                        break
        case "S" : softClip = softClip "S" len " "
			if ( pos == 1 ) {
				startsoftclip = len
				rlen = len
			}
                        pos = pos + len
			totalClip = totalClip + len
                        break
        case "H" : hardClip = hardClip "H" len " "
                        # pos does not alter for hard clip 
			totalClip = totalClip +	len
                        break

	default:
		break

	}


#  printf("len %s\n",len)

if ( addPos == 1 ) {
 for ( j=rlen; j<(rlen+len); j++ ) {
	if ( j % 10 != 0 ) {
		kspace = kspace " "
	}
        if ( j % 10 == 0 ) {
#		k = int(j/10)
		k = sprintf("%06i",j)  # format K with leading zeroes
#		print k
		if ( kStr == "" ) {
		   kStr = kspace
		} else {
		   kStr = kStr "|" j kxspace substr(kspace,1,(9-length(j)))
		   kspace = ""
		   kxspace = ""
		}
	}
 }
 rlen = rlen + len
 addPos = 0
}

# mark inserts
if ( addIns == 1 ) {
 kxspace = kxspace ","
 for ( j=rlen; j<(rlen+len); j++ ) {
{
	 kxspace = kxspace ","
        }
 }
 kxspace = kxspace "," 
 addIns = 0
}

# printf("%s \n",read_seq);    # see output grow for each cigar 

}  # for each cigar

# align ref to our read
k=1
j=1
refAd = ""
refMis = ""
mismatchCount = 0
 while ( j <= (length(read_seq)) ) {
	switch ( substr(read_seq,j,1) ) {
	case "'" :      refAd = refAd "'"
                        refMis = refMis "'"
			j = j + 1
			while ( substr(read_seq,j,1) != "'" ) { 
		        	refAd = refAd "+"
			        refMis = refMis "+"
				j = j + 1
			}
			refAd = refAd "'"
                        refMis = refMis "'"
                        j = j + 1
			break
	case "-" : 	refAd = refAd (substr(refA,k,1))
			refMis = refMis "-"
			k = k + 1
			j = j + 1
			break
	default :	refAd = refAd (substr(refA,k,1))	
			if ( substr(read_seq,j,1) == toupper(substr(refA,k,1)) ) {
				refMis = refMis "."
			} else {
				refMis = refMis "x"
				mismatchCount =	mismatchCount + 1
			}
			j = j + 1
			k = k + 1
		break
	}
}


# output:

if ( outview == "terminal" ) {    # terminal is set if output is not being piped. Print sequence, Ref and indicators 80 base pairs/line. 
	j = 1
	k = length(read_seq)
	print "Legend:  line 1: aligned seq. line 2: reference seq. line 3: insert +/delete -/mismatch x/: indicators. lines 0 : position in aligned sequence."
	print " "
        printf("CIGAR (320max): %s \n",substr(cig,0,320));   # OK?
	while ( k > j ) {
	        printf(" %s \n",substr(kStr,j,80));
	        printf("1 %s \n",substr(read_seq,j,80));
	        printf("2 %s \n",substr(refAd,j,80));
	        printf("3 %s \n",substr(refMis,j,80));
#	        printf(" %s \n",substr(kStr,j,80));
		printf("\n")
		j = j + 80
	}
} else {  # piped output will print read on one line.
	print "Legend:  line 1: aligned seq. line 2: reference seq. line 3: insert +/delete -/mismatch x/: indicators. lines 0/4- : position in aligned sequence."
	print " "
        printf("Cigar: %s \n \n",cig);
	printf(" %s \n",kStr);
	printf("1 %s \n",read_seq);
	printf("2 %s \n",refAd);
	printf("3 %s \n",refMis);
	printf(" %s \n",kStr);
}

# printf(" %s \n",refA);



print "Info:"
printf(" = and X, just print seq base, P prints \"P\", N prints \"N\", D \"-\", I \"'+'\" (inserts are enclosed in '), clipping not printed. \n") 
if ( hardClip == "") { hardClip = "-" }
printf("Inserts: %s, Deletes: %s, Matches: %s, Miss matches : %s. (Note: matches using M-I-D cigars only)\n",inserts,deletes,matches,mismatchCount)
printf("Soft clipping: %s,  Hard clipping: %s, total clip: %s.  \nRead Length (less clipping): %s  Reference Length: %s.             >>> disbamer <<< \n",softClip,hardClip,totalClip,(length(seq)-totalClip),length(ref))
print " "

}
