# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2019 Albert Ou <aou@eecs.berkeley.edu>

# CWAL_DISTFILES(<VERSION>, <SETS...>)
# Fetch and extract the distributions listed in SETS, using the release
# specified by VERSION.
#
define([CWAL_DISTFILES],
[M4_DIVERT_TEXT(_INIT_,
[export BSDINSTALL_DISTDIR='CWAL_WRKDIR()/dist']
[export BSDINSTALL_DISTSITE='http://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/$1']
[export DISTRIBUTIONS='M4_FOREACH_SEP([_SET], [shift($@)], [_SET().txz], [ ])'])]dnl
[M4_DIVERT_TEXT(_INSTALL_,
[mkdir -p -- "[$]{BSDINSTALL_DISTDIR}"]
[bsdinstall distfetch]
[bsdinstall checksum]
[bsdinstall distextract]
[bsdinstall entropy]
[bsdinstall config])])

##
## Console
##

define([CWAL_CONSOLE_EFI],
[CWAL_LOADERCONF(
[boot_multicons="YES"]
[console="efi,vidconsole"],
[CWAL_CONSOLE])])

define([CWAL_CONSOLE_SERIAL],
[CWAL_LOADERCONF(
[boot_multicons="YES"]
[boot_serial="YES"]
[console="comconsole,vidconsole"]
[comconsole_speed="$1"],
[CWAL_CONSOLE])])
