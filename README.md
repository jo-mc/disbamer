disbamer - using bash and awk scripts to show the alignment of a read to reference, in a terminal session.

### - D - I - S - B - A - M - E - R -

#### Display an aligned read sequence in a bam file alongside its reference sequence, showing inserts, deletes and mismatches.

#### for best results pipe to less -S. or redirect to a file.

##### Requires: SAMTOOLS  plus - the line number of the read to display in the bam file. 
(to obtain the line number: samtools view file.bam | less -S   then use -N to see line numbers, or use grep sed etc...)
the first read is line 1, second read is line 2 etc..
##### Setup :
###### 1. soft link in current directory to your sam/bam file. named sam.lnk
<code>	configure: > ln -s /path/to/sam/bam/file.bam sam.lnk </code>
###### 2. soft link to the reference file associated with the sam/bam file, named ref.lnk (regions [chromosome name] must match from SAM file to Ref file.)
<code>	configure: > ln -s /path/to/reference/file.fna ref.lnk </code>
###### note: Links, sam.lnk & ref.lnk, in repository point to sample sam and reference files, READS 1, 2, and 3 are provided for demonstration purposes.
#### RUN :
#####  > bash disbamer.sh 2 | less -S
###### 2 = fourth read in bam file, on the fourth line of view output (no header) and pipe to less (-S no line wrap)

##### Sample output:
```
------ Calling samtools view for file chr6alignGRCh38.sam to display read in line : 43
bam path: /hpcfs/chr6HG002/chr6alignGRCh38.sam
ref path: /hpcfs/ref/GRCh38p13/GCA_000001405.28_GRCh38.p13_genomic.fna

---------R-E-A-D----B-A-M------------ (samtools sam.lnk)
read a3cfd3c4-534b-4138-8d63-058865033f61
flag 0
region ML143369.1
position 16790
quality 0
cigar 32S20M3D56M1I11M1D17M1I24M1I66M1D46M2D56M1D45M1I3M1D48M16S
sequence CAATTTGTACTTCGTTCAGTTACGTATTACTTTAAATATGGTACTGAAAA ....

---------l-e-n-g-t-h----------------- (cigtoRefLen.awk)
matching reference length required : 401

---------r-e-f-e-r-e-n-c-e----------- (getrefseq.awk ref.lnk)
Please Wait! getting matching reference: ----may take some time.....

---------g-e-n-o-m-i-c---v-i-e-w----- (viewread.awk)  
Legend:  line 1: aligned seq. line 2: reference seq. line 3: insert +/delete -/mismatch x/: indicators. lines 4- : position in aligned sequence.
 
1 TTAAATATGGTACTGAAAAT---AAACAGAATATTTGTATGGGTACTTATCATTAATGTACGTAGCTGAAATTACACAG'A'GACCTGAAGAA-TTTTGAAGCATTGAGCT'A'AAGGTTAATTGCTGAATGATGGGA'C'CTAATACTTTGAC
2 ttaaatatggtactgaaaataagaaacagaatggttgtatgggtacttaTCATTAATGTACGTAGCTGAAATTACACAG'+'GGCCTGAAGAATTTTTGAAGCATTGAGCT'+'AAGGTTAATTGCTGAATGATGGGA'+'CTAATACTTTGAC
3 ....................---.........xx.............................................'+'.x.........-.................'+'........................'+'.............
  ........0.........0.........0.........0.........0.........0.........1.........1'+'.........1.........1.........'+'1.........1.........1...'+'......1......
  ........4.........5.........6.........7.........8.........9.........0.........1'+'.........2.........3.........'+'4.........5.........6...'+'......7......
  ........0.........0.........0.........0.........0.........0.........0.........0'+'.........0.........0.........'+'0.........0.........0...'+'......0......
 * Info:
 = and X, just print seq base, P prints "P", N prints "N", D "-", I "'+'" (inserts are enclosed in '), soft clip not printed. 
Soft clipping: S32 S16 ,  Hard clipping: -, total clip: 48.  Read Length (less clipping): 396  Reference Length: 403    Miss matches : 4.             >>> thankyou. 

```
Design: see [disbamer_code_diagrams.pdf](./disbamer_code_diagrams.pdf) 
