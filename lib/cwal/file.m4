# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2019 Albert Ou <aou@eecs.berkeley.edu>

# _CWAL_HEREDOC(<CMD>, <ERRMSG>, [TEXT])
# Generate a heredoc from substituting the output of CMD.
# Trailing TEXT is appended after the opening delimiter.
#
define([_CWAL_HEREDOC],
[<<'!EOF'$3]
[ifdef([esyscmd],, [M4_FATAL([esyscmd extension is required])])]dnl
[esyscmd([$1])]dnl
[ifelse(sysval(), [0],, [M4_FATAL([$0: $2])])]dnl
[!EOF])


# FIXME: Select Base64 decoder based on platform

# CWAL_FILE(<SRC>, <DEST>)
# Copy the contents of file SRC to the path DEST.
#
define([CWAL_FILE],
[base64 -d > $2 _CWAL_HEREDOC([bin/encode $1], [base64 encoding failed])])

# CWAL_FILE_PIPE(<SRC>, <CMD>)
# Pipe the contents of file SRC to CMD.
#
define([CWAL_FILE_PIPE],
[base64 -d _CWAL_HEREDOC([bin/encode $1], [base64 encoding failed], [ |])]
[$2])


# CWAL_OVERLAY(<SRCDIR>, <DESTDIR>)
# Extract the archived contents of directory SRCDIR into DESTDIR.
#
define([CWAL_OVERLAY],
[base64 -d _CWAL_HEREDOC([tar -cz -f - -C $1 . | bin/encode],
[base64 encoding failed], [ |])]
[tar -xzp -f - -C $2 --no-same-owner])])
