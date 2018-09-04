# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2019 Albert Ou <aou@eecs.berkeley.edu>

M4_DIVERT_TEXT(_INIT_, [export BSDINSTALL_CHROOT=/mnt])
define([CWAL_CHROOTDIR], ["[$]{BSDINSTALL_CHROOT}$1"])

define([CWAL_WRKDIR], [/tmp/cwal])
M4_DIVERT_TEXT(_INIT_,
[mkdir -p -- CWAL_WRKDIR()]
[mount -t tmpfs tmpfs CWAL_WRKDIR()]
[_clean() { umount CWAL_WRKDIR() ; }]
[trap _clean EXIT INT TERM])


# CWAL_LOADERCONF(<TEXT>, <GUARD>)
# Append to loader.conf(5) file.
#
define([CWAL_LOADERCONF],
[define([_USE_LOADERCONF])]dnl
[M4_DIVERT_ONCE(_LOADER_, [$1], [_LOADER_$2])])


# CWAL_SYSRC(<RCFILE>, <VARIABLE...>)
# Change rc.conf(5) variables.
#
define([CWAL_SYSRC],
[M4_DIVERT_TEXT(_CONFIG_,
[touch -- CWAL_CHROOTDIR([/etc/rc.conf.d/$1])]
[sysrc -f CWAL_CHROOTDIR([/etc/rc.conf.d/$1]) M4_JOIN([ ], shift($@))])])
