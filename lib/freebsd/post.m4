# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2019 Albert Ou <aou@eecs.berkeley.edu>

##
## fstab(5)
##

ifdef([_USE_FSTAB],
[M4_DIVERT_TEXT(_CONFIG_,
[cat > CWAL_CHROOTDIR([/etc/fstab]) <<!EOF]
[#
# fstab(5): static filesystem information
#
]
[undivert(_FSTAB_)]dnl
[!EOF])])

##
## loader.conf(5)
##

ifdef([_USE_LOADERCONF],
[M4_DIVERT_TEXT(_CONFIG_,
[cat > CWAL_CHROOTDIR([/boot/loader.conf]) <<!EOF]
[#
# loader.conf(5): system bootstrap configuration information
#
]
[undivert(_LOADER_)]dnl
[!EOF])])

##
## Hostname
##

CWAL_SYSRC([hostname], ['hostname=HOST()'])

##
## Miscellaneous
##

M4_DIVERT_TEXT(_CONFIG_,
[chroot CWAL_CHROOTDIR() chpass -p ]dnl
['[$]6[$]HhWBWtEUdpFryd10$EZykwdLASFwuCDtTA91s8NqzUdXrp2Rlb8kLn6ZYsB/xIhkIkTr3s38oaQVppOj0zl/Yitr92tIr/lKf3tWCD1' root]
[for file in '.history' '.lesshst' '.viminfo' ; do]
[	install -o root -g wheel -m 0600 -f schg /dev/null CWAL_CHROOTDIR([/root/[$]{file}])]
[done])
