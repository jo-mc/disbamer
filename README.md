disbamer - using bash and awk scripts to show the alignment of a read to reference, in a terminal session.

### - D - I - S - B - A - M - E - R -

#### Display an aligned read sequence in a bam file alongside its reference sequence, showing inserts, deletes and mismatches.
 
 script design: https://jo-mc.github.io/disbamer/   ....  (.io built with https://bookdown.org/yihui/bookdown/github.html)

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
#####  > bash disbamer.sh 3 | less -S
###### 3 = third read in bam file, on third line if using samtools view (no header) and pipe to less (-S no line wrap)

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
Soft clipping: S32 S16 ,  Hard clipping: -, total clip: 48.  Read Length (less clipping): 396  Reference Length: 403    Miss matches : 4.             >>> disbamer. 

```
Design: see [disbamer_code_diagrams.pdf](./disbamer_code_diagrams.pdf) 

_____________________________________________________________________________________________________________________________________________________________

#### Other tools comparision: 1. disbamer, 2. nucleotide BLAST, 3. samtools tview

##### disbamer for read 28 of aligned nanopore reads (truncated, full read 12,406 nucleotides is in output.), command: ```bash disbamer.sh 28 | less -S```
```
---------R-E-A-D----B-A-M------------ (samtools sam.lnk)
read f45d2fa2-3947-4fc6-a6d7-93c115c88420
flag 0
region CM000668.2
position 67414
quality 1
cigar    |- 2997 -| :  31S7M1D14M1I4M2I10M1D26M1I20M1I10M1I31M2I8M1I15M1I .... I3M1I34M1D46M2D17M3S.
sequence |- 12406 -| :  ATACGAATAAGAGTGTGGGCGATAACCTAAATAAGATATATCTGAATATA ....  AACTACAATGCAGATGATGC.
---------g-e-n-o-m-i-c---v-i-e-w----- (xviewread.awk) note 'x' test
Legend:  line 1: aligned seq. line 2: reference seq. line 3: insert +/delete -/mismatch x/: indicators. lines 0/4- : positio

           |150      |160,,,,,,,      |170      |180      |190      |200,,,      |210      |220,,,      |230,,,      |240
1 AGTATAT-TTTTATAAATGTTT'A'AAAT'AA'AAGCATACTT-AAATGGCAAAAACATAATACATATAT'A'AATTTTCTTATGGCAGGAGG'A'AGGAAACAGG'A'GCAAGGCACAGGG
2 agtatatattttataaatgttt'+'aaat'++'aagcatacttaaaatggcaaaaacataatacatatat'+'aattttcttatggCAGGAGG'+'AGGAAACAGG'+'GCAAGGCACAGGG
3 .......-..............'+'....'++'..........-..........................'+'....................'+'..........'+'.............
           |150      |160,,,,,,,      |170      |180      |190      |200,,,      |210      |220,,,      |230,,,      |240
Info:
 = and X, just print seq base, P prints "P", N prints "N", D "-", I "'+'" (inserts are enclosed in '), clipping not printed.
Inserts: 439, Deletes: 567, Matches: 11833, Miss matches : 431. (Note: matches using M-I-D cigars only)
```
##### Nucleotide BLAST will display submitted sequence (or part of) aligned to reference (```https://blast.ncbi.nlm.nih.gov/Blast.cgi```):
```Submitted sequence:  AAATAAAAGCATACTTAAATGGCAAAAACATAATACATATATAAATTTTCTTATGGCAGGAGGAAGGAAACAGGAGCAAGGCACAGGG
database: Nucleotide collection (nr/nt)
organism: human (taxid:9606)
```
```
Human DNA sequence from clone RP1-24O22 on chromosome 6, complete sequence
Sequence ID: AL353654.29Length: 86701Number of Matches: 1
Related Information
Genome Data Viewer-aligned genomic context
Range 1: 7440 to 7519 GenBank Graphics
Alignment statistics for match #1
Score	Expect	Identities	Gaps	Strand
118 bits(130)	1e-24	79/83(95%)	4/83(4%)	Plus/Plus
Query  7     AAGCATACTTAAA-TGGCAAAAACATAATACATATATAAATTTTCTTATGGCAGGAGGAA  65
             ||||||||||||| ||||||||||||||||||||||| |||||||||||||||||||| |
Sbjct  7440  AAGCATACTTAAAATGGCAAAAACATAATACATATAT-AATTTTCTTATGGCAGGAGG-A  7497

Query  66    GGAAACAGGAGCAAGGCACAGGG  88
             ||||||||| |||||||||||||
Sbjct  7498  GGAAACAGG-GCAAGGCACAGGG  7519
```
##### samtools tview (shows multiple reads aligning to reference)
command: ```samtools tview -d T -p CM000668.2:67414  /hpcfs/groups/phoenix-hpc-rc003/joe/correction/chm13/chr6nanop.bam ref.lnk ```
```
           67421        67431                67441             67451
ag***ta*tatattttat*aa**atg**ttt***a***aa*t**aag*c***a*tact**t*aaa**atggc*a*aaaac
..   .. .......... ..  ...  ...   .   .. .  ... .   . ....  . ...  ..... . .....
=C***C======S=====*==**.C=**===***=***=W*=**===*=***=*=CA=**=*===**=C==.*=*===.A
==***=.*C======.==*==**===**MC=***=***==*=**=G=*=***=*====**R*.======.==*=*====A
==***C=*===.A=====*=W==.==**==C***.***==*=**===*R***=*====**=*=.C**=====*=*M====
w=***m,*bk=,======*==**r=m**kbk***=***,=*=**===*=***=*=n=g**r*bk=**,====***====h
=======*==========*==**===**===***=***==*=**===*=***=*====*****==**=====***=====
=,***==*==ac======*k=**===**===***,***,=*=**===*=***=*==g=**=**==**,c===*=*==h==
==***==*==v=abbk=a*==**===**===***v***=c*g**bk=*a***=*====**=**==**h=cab*k*=,===
==***==*=============**===**===*******==*=**=***=***=*====**=*===**==*==*=*=====
==***==*==========*==**===**===***=***==*=**=***=***=*====**=**==**=====*=*=====
```
