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
# This file returns the 10 code points in Unicode Version 6.0.0 that match
# any of the following regular expression constructs:
# 
#         \p{Word_Break=ExtendNumLet}
#         \p{WB=EX}
#         \p{Is_Word_Break=ExtendNumLet}
#         \p{Is_WB=EX}
# 
#         \p{General_Category=Connector_Punctuation}
#         \p{Gc=Pc}
#         \p{Category=Connector_Punctuation}
#         \p{Is_General_Category=Pc}
#         \p{Is_Gc=Connector_Punctuation}
#         \p{Is_Category=Pc}
# 
#         \p{Connector_Punctuation}
#         \p{Is_Connector_Punctuation}
#         \p{Pc}
#         \p{Is_Pc}
# 
# perluniprops.pod should be consulted for the syntax rules for any of these,
# including if adding or subtracting white space, underscore, and hyphen
# characters matters or doesn't matter, and other permissible syntactic
# variants.  Upper/lower case distinctions never matter.
# 
# A colon can be substituted for the equals sign, and within each group
# above, anything to the left of the equals (or colon) can be combined with
# anything to the right.  Thus, for example,
#         \p{Is_Category: Connector_Punctuation}
# is also valid.
# 
# The format of the lines of this file is: START\tSTOP\twhere START is the
# starting code point of the range, in hex; STOP is the ending point, or if
# omitted, the range has just one code point.  Numbers in comments in
# [brackets] indicate how many code points are in the range.

return <<'END';
005F		
203F	2040	# [2]
2054		
FE33	FE34	# [2]
FE4D	FE4F	# [3]
FF3F		
END
