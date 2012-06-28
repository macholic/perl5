# !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
# This file is machine-generated by lib/unicore/mktables from the Unicode
# database, Version 6.0.0.  Any changes made here will be lost!

# !!!!!!!   INTERNAL PERL USE ONLY   !!!!!!!
# This file is for internal use by the Perl program only.  The format and even
# the name or existence of this file are subject to change without notice.
# Don't use it directly.

# This file is for tables that are not necessarily related:  To conserve
# resources, every table that matches the identical set of code points in
# this version of Unicode uses this file.  Each one is listed in a separate
# group below.  It could be that the tables will match the same set of code
# points in other Unicode releases, or it could be purely coincidence that
# they happen to be the same in Unicode 6.0.0, and hence may not in other
# versions.
# 
# This file returns the 22 code points in Unicode Version 6.0.0 that match
# any of the following regular expression constructs:
# 
#         \p{ASCII_Hex_Digit=Yes}
#         \p{AHex=Y}
#         \p{Is_ASCII_Hex_Digit=T}
#         \p{Is_AHex=True}
# 
#         \p{ASCII_Hex_Digit}
#         \p{Is_ASCII_Hex_Digit}
#         \p{AHex}
#         \p{Is_AHex}
# 
#         \p{PosixXDigit}
#         \p{Is_PosixXDigit}
# 
#     Meaning: [0-9A-Fa-f]
# 
# perluniprops.pod should be consulted for the syntax rules for any of these,
# including if adding or subtracting white space, underscore, and hyphen
# characters matters or doesn't matter, and other permissible syntactic
# variants.  Upper/lower case distinctions never matter.
# 
# A colon can be substituted for the equals sign, and anything to the left of
# the equals (or colon) can be combined with anything to the right.  Thus,
# for example,
#         \p{Is_AHex: Yes}
# is also valid.
# 
# The format of the lines of this file is: START\tSTOP\twhere START is the
# starting code point of the range, in hex; STOP is the ending point, or if
# omitted, the range has just one code point.  Numbers in comments in
# [brackets] indicate how many code points are in the range.

return <<'END';
0030	0039	# [10]
0041	0046	# [6]
0061	0066	# [6]
END