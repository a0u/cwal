# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2019-2021 Albert Ou <aou@eecs.berkeley.edu>

##
## Stage 3
##

# Download and extract stage3 tarball.
M4_DIVERT_TEXT(_INSTALL_,
[distfile="$(curl -s -L "GENTOO_DISTSITE()/latest-stage3-GENTOO_ARCH()[]]dnl
[M4_IFBLANK([GENTOO_DISTNAME()],, [-GENTOO_DISTNAME()]).txt" | ]dnl
[sed -n '/^#/b;s/[[:space:]].*//p;q')"]
[test -n "[$]{distfile}"]
[curl -L "GENTOO_DISTSITE()/[$]{distfile}" | tar -xJp -f - -C CWAL_CHROOTDIR()])

# Mount pseudo-filesystems in chroot.
# Populate resolv.conf(5) file.
M4_DIVERT_TEXT(_INSTALL_,
[mount -t proc none CWAL_CHROOTDIR()/proc]
[mount -R --make-rslave /dev CWAL_CHROOTDIR()/dev]
[mount -R --make-rslave /sys CWAL_CHROOTDIR()/sys]
[! test -r /etc/resolv.conf || install -o root -g root -m 0644 /etc/resolv.conf CWAL_CHROOTDIR([/etc])])

# Unpack /etc overlay.
M4_DIVERT_TEXT(_INSTALL_,
[CWAL_OVERLAY([src/gentoo/etc], [CWAL_CHROOTDIR([/etc])])])

# Populate portage(5) tree.
CWAL_CHROOT(_INSTALL_, [emerge-webrsync])

# Select profile.
CWAL_CHROOT(_INSTALL_, [eselect profile set GENTOO_PROFILE()])

CWAL_CHROOT(_INSTALL_, [emerge --sync])
CWAL_EMERGE(_INSTALL_, [-1], [sys-apps/portage])

##
## initramfs
##

CWAL_EMERGE(_KERNEL_,
	[sys-kernel/genkernel],
	[ifdef([_USE_BTRFS], [sys-fs/btrfs-progs])])

# Edit genkernel.conf file.
M4_DIVERT_TEXT(_KERNEL_,
[sed -i ']
[ifdef([_USE_LUKS], [/LUKS=/c LUKS="yes"
])]dnl
[ifdef([_USE_BTRFS], [/BTRFS=/c BTRFS="yes"
])]dnl
[/DEFAULT_KERNEL_CONFIG=/a KERNEL_OUTPUTDIR="CWAL_KBUILDDIR()"]
[/COMPRESS_INITRD_TYPE=/c COMPRESS_INITRD_TYPE="zstd"]
[' CWAL_CHROOTDIR([/etc/genkernel.conf])])

# Generate genkernel(5) initramfs.
CWAL_CHROOT(_KERNEL_,
[genkernel ifdef([_USE_LUKS], [--luks ])ifdef([_USE_BTRFS], [--btrfs ])initramfs])

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
## Post-install
##

# Set default root password.
CWAL_CHROOT(_CONFIG_,
[usermod root -p '[$]6[$]AfAC6maIqOn5IUPB$nUYkPz62M9mrjC9pLB8V99AykxCdtG/4vw8r/LsRl6ctxFkffPf7rq8.MVPAWh6.mY/jVGjWJEmAJsS7.jyXI.'])
