# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2018 Albert Ou <aou@eecs.berkeley.edu>

# CWAL_FSTAB(<DEVICE>, <FILE>, <TYPE>, <OPTIONS>, <DUMP>, <PASSNO>)
# Append to fstab(5) file.
#
define([CWAL_FSTAB],
[define(_USE_FSTAB)]dnl
[M4_DIVERT_TEXT(_FSTAB_,
[$1	$2	$3	M4_IFBLANK([$4], [rw], [$4])	$5 $6])])


# CWAL_UFS(<DEVICE>, <MNTDIR>, <OPTIONS>, <LABEL>)
# Create a UFS2 filesystem.
#
define([CWAL_UFS],
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for device])])]dnl
[M4_DIVERT_TEXT(_FORMAT_,
[newfs -O 2 -U -t -L $4 CWAL_DEVNODE([$1])]
[install -d -o root -g wheel -m 0755 CWAL_CHROOTDIR([$2])]
[mount -o '$3' CWAL_DEVNODE([$1]) CWAL_CHROOTDIR([$2])])]dnl
[CWAL_FSTAB([CWAL_DEVNODE([$1])], [$2], [ufs], [$3], [0], [2])])

# CWAL_ZPOOL(<POOL>, <VDEVS>, <DATASETS...>)
# Create a ZFS pool.
#
# NOTE: /boot is assumed to be part of the root dataset.
#
define([CWAL_ZPOOL],
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for pool])])]dnl
[M4_IFBLANK([$2], [M4_FATAL([$0: non-empty argument required for vdev])])]dnl
[pushdef([_ZFS_POOL], [$1])]dnl
[M4_DIVERT_ONCE(_INIT_,
[kldstat -q -m zfs || kldload zfs]
[sysctl vfs.zfs.min_auto_ashift=12], [_INIT_ZFS])]dnl
[M4_DIVERT_TEXT(_FORMAT_,
[zpool create -f -R CWAL_CHROOTDIR() -m none -O atime=off -O canmount=off -O checksum=sha256 -O compression=lz4 $1 $2]
[zfs create -o mountpoint=/ $1/root]
[zpool set bootfs=$1/root $1]
[M4_JOIN([
], shift(shift($@)))])]dnl
[CWAL_LOADERCONF(
[zfs_load="YES"]
[vfs.root.mountfrom="zfs:$1/root"],
[$0])]dnl
[CWAL_SYSRC([zfs], ['zfs_enable=YES'])]dnl
[popdef([_ZFS_POOL])])

# CWAL_ZFS(<PATH>, <PROPERTIES...>)
# Create a ZFS dataset.
#
define([CWAL_ZFS],
[ifdef([_ZFS_POOL],, [M4_FATAL([$0: must be used within CWAL_ZPOOL macro])])]dnl
[pushdef([_ZFS_DATASET],
[ifelse(substr([$1], [0], [1]), [/], [substr([$1], [1])], [$1])])]dnl
[zfs create ifelse(index(_ZFS_DATASET(), [/]), [-1], [-o mountpoint=/_ZFS_DATASET() ])]dnl
[ifelse(eval([($#) > 1]), [1], [M4_FOREACH([_PROP], [shift($@)], [-o _PROP() ])])]dnl
[_ZFS_POOL()/_ZFS_DATASET()[]]dnl
[popdef([_ZFS_DATASET])])


# CWAL_SWAP(<DEVICE>)
# Create a swap partition.
#
define([CWAL_SWAP],
[CWAL_FSTAB([CWAL_DEVNODE([$1])], [none], [swap], [sw], [0], [0])])

# CWAL_SWAP_GELI(<DEVICE>)
# Create an encrypted swap partition.
#
define([CWAL_SWAP_GELI],
[CWAL_FSTAB([CWAL_DEVNODE([$1]).eli], [none], [swap],
[sw,ealgo=GELI_EALGO(),keylen=GELI_KEYLEN(),sectorsize=4096], [0], [0])])


# CWAL_TMPFS(<MNTDIR>, <OPTIONS>)
# Create a tmpfs(5) filesystem.
#
define([CWAL_TMPFS],
[M4_DIVERT_TEXT(_FORMAT_,
[install -d -o root -g wheel -m 0755 CWAL_CHROOTDIR([$1])]
[mount -o '$2' -t tmpfs tmpfs CWAL_CHROOTDIR([$1])[]])]dnl
[CWAL_FSTAB([tmpfs], [$1], [tmpfs], [$2], [0], [0])]dnl
[CWAL_LOADERCONF([tmpfs_load="YES"], [$0])])

# CWAL_NULLFS(<TARGET>, <MNTDIR>)
# Create a nullfs(5) filesystem.
#
define([CWAL_NULLFS],
[M4_DIVERT_TEXT(_FORMAT_,
[install -d -o root -g wheel -m 0755 CWAL_CHROOTDIR([$1]) CWAL_CHROOTDIR([$2])]
[mount_nullfs CWAL_CHROOTDIR([$1]) CWAL_CHROOTDIR([$2])[]])]dnl
[CWAL_FSTAB([$1], [$2], [nullfs], [rw], [0], [0])]
[CWAL_LOADERCONF([nullfs_load="YES"], [$0])])


# CWAL_CHMOD(<MODE>, <PATH...>)
#
define([CWAL_CHMOD],
[M4_DIVERT_TEXT(_INSTALL_,
[chmod $1[]M4_FOREACH([_DIR], [shift($@)], [ CWAL_CHROOTDIR([_DIR()])])])])
