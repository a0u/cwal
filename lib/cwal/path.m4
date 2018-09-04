# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2019 Albert Ou <aou@eecs.berkeley.edu>

# CWAL_DEVNODE(<DEVICE>)
# Prepend "/dev" prefix if not present.
#
define([CWAL_DEVNODE],
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for device])])]dnl
[ifelse(index([$1], [/dev/]), [0], [$1], [/dev/$1])])

# CWAL_DEVNAME(<DEVICE>)
# Strip "/dev" prefix if present.
#
define([CWAL_DEVNAME],
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for device])])]dnl
[ifelse(index([$1], [/dev/]), [0], [substr([$1], [5])], [$1])])
