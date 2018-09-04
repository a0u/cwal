divert(-1)
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Copyright 2018 Albert Ou <aou@eecs.berkeley.edu>

# Inspired by and partly derived from the M4sugar library in Autoconf

changequote()
changequote([, ])

##
## Diagnostics
##

# M4_INFO(<MESSAGE>)
define([M4_INFO],
[errprint(ifdef([__file__], [__file__:__line__: ])[$1])])

# M4_WARNING(<MESSAGE>)
define([M4_WARNING], [M4_INFO([warning: $1])])

# M4_FATAL(<MESSAGE>, [EXIT-STATUS])
define([M4_FATAL],
[M4_INFO([error: $1])m4exit(ifelse([$2],, 1, [$2]))])

##
## Quoting manipulation
##

# M4_QUOTE(<ARGS...>)
# Return ARGS as a single argument.
#
define([M4_QUOTE], [[$*]])

# M4_DQUOTE(<ARGS...>)
# Return ARGS as a quoted list of quoted arguments.
#
define([M4_DQUOTE], [[$@]])

##
## Text
##

# M4_JOIN(<SEP>, <ARGS...>)
# Concatenate ARGS with specified separator SEP, ignoring empty arguments.
#
define([M4_JOIN],
[ifelse([$#], [1],,
	[$#], [2], [$2],
	[ifelse([$2],,, [$2[]_])$0([$1], shift(shift($@)))])])

define([_M4_JOIN],
[ifelse([$#$2], [2],,
	[ifelse([$2],,, [$1$2])[]$0([$1], shift(shift($@)))])])

# M4_LSTRIP(<STRING>, <PREFIX>)
# Remove all leading occurrences of PREFIX from STRING.
#
#define([M4_LSTRIP],
#[ifelse([$2],, [$1], M4_QUOTE(substr([$1], [0], len([$2]))), [$2],
#[$0(M4_QUOTE(substr([$1], len([$2]))), [$2])], [$1])])

# M4_EXPAND_ONCE(<TEXT>, <GUARD>)
# Expand TEXT unless already present, determined by the existence of GUARD.
#
define([M4_EXPAND_ONCE], [ifdef([$2],, [define([$2])$1])])

##
## Conditionals
##

# M4_IFBLANK(<COND>, [IF-BLANK], [IF-TEXT])
# Expand to IF-BLANK if COND consists solely of whitespace (space, tab,
# linefeed); otherwise, expand to IF-TEXT.
#
define([M4_IFBLANK],
[ifelse(translit([[$1]], [ ][	][
]),, [$2], [$3])])

##
## Iteration
##

# M4_COUNT(<ARGS...>)
define([M4_COUNT], [$#])

# M4_CAR(<ARGS...>)
# Return the first argument of ARGS.
#
define([M4_CAR], [[$1]])

# M4_CDR(<ARGS...>)
# Return a quoted list of arguments in ARGS, excluding the first.
#
define([M4_CDR],
[ifelse([$#], [0], [M4_FATAL([$0: missing argument])],
	[$#], [1],,
	[M4_DQUOTE(shift($@))])])

# M4_FOREACH(<VARIABLE>, <LIST>, <EXPRESSION>)
# Expand EXPRESSION assigning each value of the LIST to VARIABLE.
#
define([M4_FOREACH],
[ifelse([$2],,, [pushdef([$1])_$0([$1], [$3],, $2)popdef([$1])])])

define([_M4_FOREACH],
[ifelse([$#], [3],,
	[define([$1], [$4])$2[]$0([$1], [$2], shift(shift(shift($@))))])])

# M4_FOREACH_SEP(<VARIABLE>, <LIST>, <EXPRESSION>, <SEP>)
# Expand EXPRESSION assigning each value of the LIST to VARIABLE.
# Output separator SEP between non-empty macro expansions.
#
define([M4_FOREACH_SEP],
[M4_JOIN([$4], M4_FOREACH([$1], [$2], [M4_QUOTE($3),]))])

##
## Diversions
##

# M4_DIVERT_PUSH(<DIVNUM>)
# Change the diversion stream to DIVNUM while stacking previous indices.
#
define([M4_DIVERT_PUSH],
[pushdef([_M4_DIVERT_STACK], divnum)divert([$1])])

# M4_DIVERT_POP([DIVNUM])
# Change the diversion stream to its previous index.
# If specified, verify that the departed stream was DIVNUM.
#
define([M4_DIVERT_POP],
[ifelse([$1],,,
	[$1], divnum,,
	[M4_FATAL([$0: diversion index mismatch: $1])])]dnl
[ifdef([_M4_DIVERT_STACK],, [M4_FATAL([$0: empty diversion stack])])]dnl
[divert(defn([_M4_DIVERT_STACK]))popdef([_M4_DIVERT_STACK])])

# M4_DIVERT_TEXT(<DIVNUM>, <TEXT>)
# Output TEXT to the diversion stream specified by DIVNUM.
#
define([M4_DIVERT_TEXT],
[M4_DIVERT_PUSH([$1])$2
M4_DIVERT_POP([$1])])

# M4_DIVERT_ONCE(<DIVNUM>, <TEXT>, <GUARD>)
# Output TEXT to the diversion stream specified by DIVNUM unless already
# present, determined by the existence of GUARD.
#
define([M4_DIVERT_ONCE],
[M4_EXPAND_ONCE([M4_DIVERT_TEXT([$1], [$2])], [$3])])
