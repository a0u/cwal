# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2019-2021 Albert Ou <aou@eecs.berkeley.edu>

define([GENTOO_ARCH], [amd64])
define([GENTOO_DISTNAME], [hardened+nomultilib])
define([GENTOO_DISTSITE], [http://distfiles.gentoo.org/releases/GENTOO_ARCH()/autobuilds])
define([GENTOO_PROFILE], [default/linux/amd64/17.1/no-multilib/hardened])

# CWAL_CHROOT(<DIVNUM>, <CMD>)
#
define([CWAL_CHROOT],
[M4_DIVERT_TEXT([$1], [chroot CWAL_CHROOTDIR() $2])])

# CWAL_EMERGE(<DIVNUM>, <EBUILD>...)
#
define([CWAL_EMERGE],
[CWAL_CHROOT([$1], [emerge --quiet-build y M4_JOIN([ ], shift($@))])])

##
## Kernel
##

define([CWAL_KBUILDDIR], [/var/tmp/portage/linux])

# CWAL_KERNEL(<CONFIG>, [EBUILD])
# Build and install a Linux kernel image from the predefined CONFIG.
#
define([CWAL_KERNEL],
[CWAL_EMERGE(_KERNEL_, [M4_IFBLANK([$2], [sys-kernel/gentoo-sources], [$2])],
[sys-kernel/linux-firmware], [sys-firmware/intel-microcode])]
[CWAL_EMERGE(_KERNEL_, [-1], [app-arch/lz4])]
[M4_DIVERT_TEXT(_KERNEL_,
[export KBUILD_OUTPUT='CWAL_KBUILDDIR()']
[install -o root -g root -m 0755 -d -- "CWAL_CHROOTDIR()/[$]{KBUILD_OUTPUT}"]
[CWAL_FILE([$1], ["CWAL_CHROOTDIR()/[$]{KBUILD_OUTPUT}/.config"])])]
[CWAL_CHROOT(_KERNEL_, [make -C /usr/src/linux olddefconfig])]
[CWAL_CHROOT(_KERNEL_, [make -C /usr/src/linux -j "$(nproc)"])]
[CWAL_CHROOT(_KERNEL_, [make -C /usr/src/linux install modules_install])]
[M4_DIVERT_TEXT(_KERNEL_, [unset KBUILD_OUTPUT])])

##
## Bootloader
##

# CWAL_SYSTEMDBOOT(<CMDLINE>)
#
# FIXME: bootctl(1) exits with a non-zero code due to missing /etc/machine-id file.
#
define([CWAL_SYSTEMDBOOT],
[CWAL_EMERGE(_CONFIG_, [sys-boot/systemd-boot])]
[M4_DIVERT_TEXT(_CONFIG_,
[test -f CWAL_CHROOTDIR()/etc/machine-id || { uuidgen | tr -d '-' > CWAL_CHROOTDIR()/etc/machine-id ; }])]
[CWAL_CHROOT(_CONFIG_, [bootctl --path CWAL_EFIDIR() install])]
[M4_DIVERT_TEXT(_CONFIG_,
[for vmlinuz in CWAL_CHROOTDIR([/boot/vmlinuz])* ; do break ; done]
[for initramfs in CWAL_CHROOTDIR([/boot/initramfs])* ; do break ; done]
[install -o root -g root -m 0444 -D -t CWAL_CHROOTDIR([CWAL_EFIDIR()/gentoo]) "[$]{vmlinuz}" "[$]{initramfs}"]
[mkdir -p -- CWAL_CHROOTDIR([CWAL_EFIDIR()/loader/entries])]
[cat > CWAL_CHROOTDIR([/CWAL_EFIDIR()/loader/loader.conf]) <<'!EOF']
[default gentoo]
[timeout 5]
[console-mode keep]
[!EOF]
[cat > CWAL_CHROOTDIR([CWAL_EFIDIR()/loader/entries/gentoo.conf]) <<!EOF]
[title	Gentoo Linux]
[linux	/gentoo/[$]{vmlinuz##*/}]
[initrd	/gentoo/[$]{initramfs##*/}]
[options	$1]
[!EOF])])

##
## Post-install
##

# CWAL_INITTAB(<ID>)
# Uncomment the entry matching ID.
#
define([CWAL_INITTAB],
[M4_DIVERT_TEXT(_CONFIG_,
[sed -i '/$1:/s/[[[:space:]]]*[#][[[:space:]]]*//' CWAL_CHROOTDIR([/etc/inittab])])])
