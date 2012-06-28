# !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
# This file is machine-generated by lib/unicore/mktables from the Unicode
# database, Version 6.0.0.  Any changes made here will be lost!

# !!!!!!!   INTERNAL PERL USE ONLY   !!!!!!!
# This file is for internal use by the Perl program only.  The format and even
# the name or existence of this file are subject to change without notice.
# Don't use it directly.

# This file returns the mapping:
#         _slc(cp)
# 
# where 'cp' is one of the 28 code points in Unicode Version 6.0.0 for which
# the mapping is not to itself.  Note that this mapping is not accessible
# through the Perl core directly.
# 
# This file is for UCD.pm so that it can construct simple mappings that would
# otherwise be lost because they are overridden by full mappings.
# 
# The simple mappings for lc for code points that have full mappings as well
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
$utf8::SwashInfo{'To_slc'}{'format'} = 'x'; # positive hex whole number; a code point
$utf8::SwashInfo{'To_slc'}{'missing'} = '<code point>'; # code point maps to itself

return <<'END';
0130		0069
1F88		1F80
1F89		1F81
1F8A		1F82
1F8B		1F83
1F8C		1F84
1F8D		1F85
1F8E		1F86
1F8F		1F87
1F98		1F90
1F99		1F91
1F9A		1F92
1F9B		1F93
1F9C		1F94
1F9D		1F95
1F9E		1F96
1F9F		1F97
1FA8		1FA0
1FA9		1FA1
1FAA		1FA2
1FAB		1FA3
1FAC		1FA4
1FAD		1FA5
1FAE		1FA6
1FAF		1FA7
1FBC		1FB3
1FCC		1FC3
1FFC		1FF3
END
