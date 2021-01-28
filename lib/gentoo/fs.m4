# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2019-2021 Albert Ou <aou@eecs.berkeley.edu>

define([CWAL_CHROOTDIR], [/mnt/gentoo[]$1])

# CWAL_UUID(<DEVICE>)
#
define([CWAL_UUID],
[M4_DIVERT_ONCE(_INIT_,
[_uuid() { blkid -p -o value -s UUID "[$]1" ; }], [_INIT_UUID])]dnl
[$(_uuid $1)])

# _CWAL_FSTAB(<DEVICE>, <FILE>, <TYPE>, <OPTIONS>, <DUMP>, <PASSNO>)
#
define([_CWAL_FSTAB],
[define(_USE_FSTAB)]dnl
[M4_DIVERT_TEXT(_FSTAB_,
[$1	$2	$3	$4	$5 $6])])

define([CWAL_FSTAB],
[_CWAL_FSTAB([UUID=CWAL_UUID([$1])], shift($@))])


# CWAL_BTRFS(<LABEL>, <DEVICE>, <OPTIONS>, <SUBVOLUMES...>)
# Create a btrfs filesystem.
#
define([CWAL_BTRFS],
[define(_USE_BTRFS)]dnl
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for label])])]dnl
[M4_IFBLANK([$2], [M4_FATAL([$0: non-empty argument required for device])])]dnl
[pushdef([_BTRFS_DEVICE], [$2])]dnl
[pushdef([_BTRFS_MNTDIR], [/mnt/btrfs])]dnl
[pushdef([_BTRFS_MNTOPTS], $3)]dnl
[M4_DIVERT_TEXT(_FORMAT_,
[mkfs.btrfs -f -L $1 _BTRFS_DEVICE()]
[mkdir -p -- _BTRFS_MNTDIR() CWAL_CHROOTDIR()]
[mount _BTRFS_DEVICE() _BTRFS_MNTDIR()]
[M4_JOIN([
], shift(shift(shift($@))))]
[umount _BTRFS_MNTDIR()])]dnl
[popdef([_BTRFS_DEVICE], [_BTRFS_MNTDIR], [_BTRFS_MNTOPTS])])

# CWAL_BTRFS_SUBVOL(<PATH>, <OPTIONS...>)
# Create a btrfs subvolume.
#
define([CWAL_BTRFS_SUBVOL],
[_$0([@M4_IFBLANK([$1],, [/$1])], [$1], _BTRFS_MNTOPTS(), shift($@))])

# _CWAL_BTRFS_SUBVOL(<PATH>, <MNTDIR>, <OPTIONS...>)
#
define([_CWAL_BTRFS_SUBVOL],
[ifdef([_BTRFS_DEVICE],, [M4_FATAL([$0: must be used within CWAL_BTRFS macro])])]dnl
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for path])])]dnl
[pushdef([_BTRFS_MNTOPTS], [M4_JOIN([,], [subvol=$1], shift(shift($@)))])]dnl
[btrfs subvolume create _BTRFS_MNTDIR()/$1]
[mount -o '_BTRFS_MNTOPTS()' _BTRFS_DEVICE() CWAL_CHROOTDIR([/$2])[]]dnl
[CWAL_FSTAB([_BTRFS_DEVICE()], [/$2], [btrfs], [_BTRFS_MNTOPTS()], [0], [0])]dnl
[popdef([_BTRFS_MNTOPTS])])

define([CWAL_BTRFS_OPTIONS], [M4_DQUOTE($@)])


# CWAL_SWAP(<DEVICE>, [LABEL])
# Add an fstab(5) entry for a swap device.
# If LABEL is specified, format a Linux swap area.
#
define([CWAL_SWAP],
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for device])])]dnl
[M4_IFBLANK([$2],, [M4_DIVERT_TEXT(_FORMAT_,
[mkswap -f -L $2 $1])])]dnl
[CWAL_FSTAB([$1], [none], [swap], [defaults,discard], [0], [0])])

# CWAL_VFAT(<DEVICE>, <MNTDIR>, <OPTIONS>, [LABEL])
# Add an fstab(5) entry for a FAT32 filesystem.
# If LABEL is specified, format a FAT32 filesystem.
#
define([CWAL_VFAT],
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for device])])]dnl
[M4_IFBLANK([$4],, [M4_DIVERT_TEXT(_FORMAT_,
[mkfs.vfat -F 32 -n $4 $1])])]dnl
[M4_DIVERT_TEXT(_FORMAT_,
[install -o root -g root -m 0755 -d CWAL_CHROOTDIR([$2])]
[mount -o '$3' $1 CWAL_CHROOTDIR([$2])])]dnl
[CWAL_FSTAB([$1], [$2], [vfat], [$3], [0], [0])])

define([CWAL_EFIDIR], [/boot/efi])

# CWAL_ESP(<DEVICE>, [LABEL])
# Add an fstab(5) entry for an EFI system partition.
# If LABEL is specified, format a FAT32 filesystem.
#
define([CWAL_ESP],
[CWAL_VFAT([$1], [CWAL_EFIDIR()], [defaults,noatime,noauto], [$2])])

# CWAL_TMPFS(<MNTDIR>, <OPTIONS>)
# Add an fstab(5) entry for a tmpfs(5) filesystem.
#
define([CWAL_TMPFS],
[M4_DIVERT_TEXT(_FORMAT_,
[install -o root -g root -m 0755 -d CWAL_CHROOTDIR([$1])]
[mount -o '$2' -t tmpfs tmpfs CWAL_CHROOTDIR([$1])[]])]dnl
[_CWAL_FSTAB([tmpfs], [$1], [tmpfs], [$2], [0], [0])])
