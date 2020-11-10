#! /usr/bin/awk -f 

# Given a read sequence, cigar string and reference sequences, print out the alignment.
#
#  usage from a bash script >   # assign read sequence, cigar string and reference sequences, to awk variables from a bash script, and call awk script:
#                               awk -v cigA="$cigarD" -v seqA="$seqD" -v refA="$seqrefD" -f viewread.awk
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
regex =  "[[:upper:]]+"; 
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
# posStr calculates the read position, will write read position vertically underneath the sequence.
posStr = ""
posStr10 = ""
posStr100 = ""
posStr1000 = ""
posStr10000 = ""
posStr100000 = ""
posStr1000000 = ""
rlen = 1
addPos = 0
addIns = 0

for ( i=1; i<n; i++ ) {
	# print arr[i] ":" brr[i+1]
	len = arr[i]

	switch( brr[i+1] ) {
	
	case "M" : read_seq = read_seq substr(seq,pos,len)
			pos = pos + len
			addPos = 1
			matches = matches + len
			break;
        case "=" : read_seq = read_seq substr(seq,pos,len)
                        pos = pos + len
                        addPos = 1
			matches = matches + len
                        break;
        case "X" : read_seq = read_seq substr(seq,pos,len)
                        pos = pos + len
                        addPos = 1
                        break;
	case "D" : for(c=0;c<len;c++) read_seq = read_seq "-"
                        addPos = 1
			deletes = deletes + len
			break;
        case "I" : read_seq = read_seq "'" substr(seq,pos,len) "'"
                        pos = pos + len
			addIns = 1
			inserts = inserts + len
                        break;
        case "N" : for(c=0;c<len;c++) read_seq = read_seq "N"
                        pos = pos + len
                        break;
        case "P" : for(c=0;c<len;c++) read_seq = read_seq "P"
                        pos = pos + len
                        break;
        case "S" : softClip = softClip "S" len " "
			if ( pos == 1 ) {
				startsoftclip = len
				rlen = len
			}
                        pos = pos + len
			totalClip = totalClip + len
                        break;
        case "H" : hardClip = hardClip "H" len " "
                        # pos does not alter for hard clip 
			totalClip = totalClip +	len
                        break;

	default:
		break;

	}


#  printf("len %s\n",len)
if ( addPos == 1 ) {
 for ( j=rlen; j<(rlen+len); j++ ) {
	if ( j % 10 != 0 ) {
		posStr = posStr "."
		posStr10 = posStr10 "."
		posStr100 = posStr100 "."
		posStr1000 = posStr1000 "."
		posStr10000 = posStr10000 "."
		posStr100000 = posStr100000 "."
                posStr1000000 = posStr1000000 "."
	}
        if ( j % 10 == 0 ) {
#		k = int(j/10)
		k = sprintf("%06i",j)  # format K with leading zeroes
#		print k
		posStr = posStr substr(k,length(k),1)
                posStr10 = posStr10 substr(k,length(k)-1,1)
                posStr100 = posStr100 substr(k,length(k)-2,1)
                posStr1000 = posStr1000 substr(k,length(k)-3,1)
                posStr10000 = posStr10000 substr(k,length(k)-4,1)
                posStr100000 = posStr100000 substr(k,length(k)-5,1)
                posStr1000000 = posStr1000000 substr(k,length(k)-6,1)
	}
 }
 rlen = rlen + len
 addPos = 0
}

# mark inserts
if ( addIns == 1 ) {
 posStr = posStr "'"; ; posStr10 = posStr10 "'";  posStr100 = posStr100 "'"; posStr1000 = posStr1000 "'"; posStr10000 = posStr10000 "'";  posStr100000 = posStr100000 "'";  posStr1000000 = posStr1000000 "'";
 for ( j=rlen; j<(rlen+len); j++ ) {
{
                posStr = posStr "+"
                posStr10 = posStr10 "+"
                posStr100 = posStr100 "+"
                posStr1000 = posStr1000 "+"
                posStr10000 = posStr10000 "+"
                posStr100000 = posStr100000 "+"
                posStr1000000 = posStr1000000 "+"
        }
 }
 posStr = posStr "'"; posStr10 = posStr10 "'";  posStr100 = posStr100 "'"; posStr1000 = posStr1000 "'"; posStr10000 = posStr10000 "'";  posStr100000 = posStr100000 "'";  posStr1000000 = posStr1000000 "'";  
 addIns = 0
}

# printf("%s \n",read_seq);    # see output grow for each cigar 
# printf("%s \n",posStr);

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

print "Legend:  line 1: aligned seq. line 2: reference seq. line 3: insert +/delete -/mismatch x/: indicators. lines 4- : position in aligned sequence."
print " "
printf("1 %s \n",read_seq);
printf("2 %s \n",refAd);
printf("3 %s \n",refMis);

# printf(" %s \n",refA);

n=split(posStr1000000,carr,"[1-9]")
if ( n > 1 ) { printf("  %s \n",posStr1000000); }
n=split(posStr100000,carr,"[1-9]")

if ( n > 1 ) { printf("  %s \n",posStr100000); }
n=split(posStr10000,carr,"[1-9]")

if ( n > 1 ) { printf("  %s \n",posStr10000); }
n=split(posStr1000,carr,"[1-9]")

if ( n > 1 ) { printf("  %s \n",posStr1000); }
n=split(posStr100,carr,"[1-9]")

if ( n > 1 ) { printf("  %s \n",posStr100); }
n=split(posStr10,carr,"[1-9]")

if ( n > 1 ) { printf("  %s \n",posStr10); }
printf("  %s \n",posStr);


print "Info:"
printf(" = and X, just print seq base, P prints \"P\", N prints \"N\", D \"-\", I \"'+'\" (inserts are enclosed in '), clipping not printed. \n") 
if ( hardClip == "") { hardClip = "-" }
printf("Inserts: %s, Deletes: %s, Matches: %s. (using M-I-D cigars only), Miss matches : %s.\n",inserts,deletes,matches,mismatchCount)
printf("Soft clipping: %s,  Hard clipping: %s, total clip: %s.  \nRead Length (less clipping): %s  Reference Length: %s.             >>> thankyou. \n",softClip,hardClip,totalClip,(length(seq)-totalClip),length(ref))
print " "

}
