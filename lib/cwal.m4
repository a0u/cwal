include(`lib/cwal/head.m4')
include([lib/cwal/path.m4])

define([CWAL_BEGIN], [include([lib/$1.m4])])
define([CWAL_END])

M4_DIVERT_TEXT([0],
[#!/bin/sh]
[set -e])
