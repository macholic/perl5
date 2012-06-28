# !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
# This file is machine-generated by lib/unicore/mktables from the Unicode
# database, Version 6.0.0.  Any changes made here will be lost!

# !!!!!!!   INTERNAL PERL USE ONLY   !!!!!!!
# This file is for internal use by the Perl program only.  The format and even
# the name or existence of this file are subject to change without notice.
# Don't use it directly.

# This file returns the synonymous mappings:
#         Joining_Type(cp)
#         Jt(cp)
# 
# where 'cp' is one of the 1610 code points in Unicode Version 6.0.0 for
# which the mapping is not to 'Non_Joining'.  Note that these mappings are
# not accessible through the Perl core directly.
# 
# For information about what this property really means, see:
# http://www.unicode.org/reports/tr44/
# 
# The format of the non-comment portions of the main body of lines of this
# file is: START\tSTOP\tMAPPING where START is the starting code point of the
# range, in hex; STOP is the ending point, or if omitted, the range has just
# one code point; MAPPING is what each code point between START and STOP maps
# to.  Numbers in comments in [brackets] indicate how many code points are in
# the range (omitted when the range is a single code point or if the mapping
# is to the null string).

# The name this swash is to be known by, with the format of the mappings in
# the main body of the table, and what all code points missing from this file
# map to.
$utf8::SwashInfo{'ToJt'}{'format'} = 's'; # string
$utf8::SwashInfo{'ToJt'}{'missing'} = 'Non_Joining';

return <<'END';
00AD		T
0300	036F	T	# [112]
0483	0489	T	# [7]
0591	05BD	T	# [45]
05BF		T
05C1	05C2	T	# [2]
05C4	05C5	T	# [2]
05C7		T
0610	061A	T	# [11]
0620		D
0622	0625	R	# [4]
0626		D
0627		R
0628		D
0629		R
062A	062E	D	# [5]
062F	0632	R	# [4]
0633	063F	D	# [13]
0640		C
0641	0647	D	# [7]
0648		R
0649	064A	D	# [2]
064B	065F	T	# [21]
066E	066F	D	# [2]
0670		T
0671	0673	R	# [3]
0675	0677	R	# [3]
0678	0687	D	# [16]
0688	0699	R	# [18]
069A	06BF	D	# [38]
06C0		R
06C1	06C2	D	# [2]
06C3	06CB	R	# [9]
06CC		D
06CD		R
06CE		D
06CF		R
06D0	06D1	D	# [2]
06D2	06D3	R	# [2]
06D5		R
06D6	06DC	T	# [7]
06DF	06E4	T	# [6]
06E7	06E8	T	# [2]
06EA	06ED	T	# [4]
06EE	06EF	R	# [2]
06FA	06FC	D	# [3]
06FF		D
070F		T
0710		R
0711		T
0712	0714	D	# [3]
0715	0719	R	# [5]
071A	071D	D	# [4]
071E		R
071F	0727	D	# [9]
0728		R
0729		D
072A		R
072B		D
072C		R
072D	072E	D	# [2]
072F		R
0730	074A	T	# [27]
074D		R
074E	0758	D	# [11]
0759	075B	R	# [3]
075C	076A	D	# [15]
076B	076C	R	# [2]
076D	0770	D	# [4]
0771		R
0772		D
0773	0774	R	# [2]
0775	0777	D	# [3]
0778	0779	R	# [2]
077A	077F	D	# [6]
07A6	07B0	T	# [11]
07CA	07EA	D	# [33]
07EB	07F3	T	# [9]
07FA		C
0816	0819	T	# [4]
081B	0823	T	# [9]
0825	0827	T	# [3]
0829	082D	T	# [5]
0859	085B	T	# [3]
0900	0902	T	# [3]
093A		T
093C		T
0941	0948	T	# [8]
094D		T
0951	0957	T	# [7]
0962	0963	T	# [2]
0981		T
09BC		T
09C1	09C4	T	# [4]
09CD		T
09E2	09E3	T	# [2]
0A01	0A02	T	# [2]
0A3C		T
0A41	0A42	T	# [2]
0A47	0A48	T	# [2]
0A4B	0A4D	T	# [3]
0A51		T
0A70	0A71	T	# [2]
0A75		T
0A81	0A82	T	# [2]
0ABC		T
0AC1	0AC5	T	# [5]
0AC7	0AC8	T	# [2]
0ACD		T
0AE2	0AE3	T	# [2]
0B01		T
0B3C		T
0B3F		T
0B41	0B44	T	# [4]
0B4D		T
0B56		T
0B62	0B63	T	# [2]
0B82		T
0BC0		T
0BCD		T
0C3E	0C40	T	# [3]
0C46	0C48	T	# [3]
0C4A	0C4D	T	# [4]
0C55	0C56	T	# [2]
0C62	0C63	T	# [2]
0CBC		T
0CBF		T
0CC6		T
0CCC	0CCD	T	# [2]
0CE2	0CE3	T	# [2]
0D41	0D44	T	# [4]
0D4D		T
0D62	0D63	T	# [2]
0DCA		T
0DD2	0DD4	T	# [3]
0DD6		T
0E31		T
0E34	0E3A	T	# [7]
0E47	0E4E	T	# [8]
0EB1		T
0EB4	0EB9	T	# [6]
0EBB	0EBC	T	# [2]
0EC8	0ECD	T	# [6]
0F18	0F19	T	# [2]
0F35		T
0F37		T
0F39		T
0F71	0F7E	T	# [14]
0F80	0F84	T	# [5]
0F86	0F87	T	# [2]
0F8D	0F97	T	# [11]
0F99	0FBC	T	# [36]
0FC6		T
102D	1030	T	# [4]
1032	1037	T	# [6]
1039	103A	T	# [2]
103D	103E	T	# [2]
1058	1059	T	# [2]
105E	1060	T	# [3]
1071	1074	T	# [4]
1082		T
1085	1086	T	# [2]
108D		T
109D		T
135D	135F	T	# [3]
1712	1714	T	# [3]
1732	1734	T	# [3]
1752	1753	T	# [2]
1772	1773	T	# [2]
17B4	17B5	T	# [2]
17B7	17BD	T	# [7]
17C6		T
17C9	17D3	T	# [11]
17DD		T
180B	180D	T	# [3]
18A9		T
1920	1922	T	# [3]
1927	1928	T	# [2]
1932		T
1939	193B	T	# [3]
1A17	1A18	T	# [2]
1A56		T
1A58	1A5E	T	# [7]
1A60		T
1A62		T
1A65	1A6C	T	# [8]
1A73	1A7C	T	# [10]
1A7F		T
1B00	1B03	T	# [4]
1B34		T
1B36	1B3A	T	# [5]
1B3C		T
1B42		T
1B6B	1B73	T	# [9]
1B80	1B81	T	# [2]
1BA2	1BA5	T	# [4]
1BA8	1BA9	T	# [2]
1BE6		T
1BE8	1BE9	T	# [2]
1BED		T
1BEF	1BF1	T	# [3]
1C2C	1C33	T	# [8]
1C36	1C37	T	# [2]
1CD0	1CD2	T	# [3]
1CD4	1CE0	T	# [13]
1CE2	1CE8	T	# [7]
1CED		T
1DC0	1DE6	T	# [39]
1DFC	1DFF	T	# [4]
200B		T
200D		C
200E	200F	T	# [2]
202A	202E	T	# [5]
2060	2064	T	# [5]
206A	206F	T	# [6]
20D0	20F0	T	# [33]
2CEF	2CF1	T	# [3]
2D7F		T
2DE0	2DFF	T	# [32]
302A	302F	T	# [6]
3099	309A	T	# [2]
A66F	A672	T	# [4]
A67C	A67D	T	# [2]
A6F0	A6F1	T	# [2]
A802		T
A806		T
A80B		T
A825	A826	T	# [2]
A8C4		T
A8E0	A8F1	T	# [18]
A926	A92D	T	# [8]
A947	A951	T	# [11]
A980	A982	T	# [3]
A9B3		T
A9B6	A9B9	T	# [4]
A9BC		T
AA29	AA2E	T	# [6]
AA31	AA32	T	# [2]
AA35	AA36	T	# [2]
AA43		T
AA4C		T
AAB0		T
AAB2	AAB4	T	# [3]
AAB7	AAB8	T	# [2]
AABE	AABF	T	# [2]
AAC1		T
ABE5		T
ABE8		T
ABED		T
FB1E		T
FE00	FE0F	T	# [16]
FE20	FE26	T	# [7]
FEFF		T
FFF9	FFFB	T	# [3]
101FD		T
10A01	10A03	T	# [3]
10A05	10A06	T	# [2]
10A0C	10A0F	T	# [4]
10A38	10A3A	T	# [3]
10A3F		T
11001		T
11038	11046	T	# [15]
11080	11081	T	# [2]
110B3	110B6	T	# [4]
110B9	110BA	T	# [2]
110BD		T
1D167	1D169	T	# [3]
1D173	1D182	T	# [16]
1D185	1D18B	T	# [7]
1D1AA	1D1AD	T	# [4]
1D242	1D244	T	# [3]
E0001		T
E0020	E007F	T	# [96]
E0100	E01EF	T	# [240]
END
