# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2018 Albert Ou <aou@eecs.berkeley.edu>

# CWAL_GPT(<DEVICES>, <PREFIX>, <BODY...>)
#
define([CWAL_GPT],
[pushdef([_GPT_INDEX])]dnl
[pushdef([_GPT_PREFIX], [$2])]dnl
[pushdef([_GPT_SUFFIX],
	[ifelse(eval((M4_COUNT($1)) > 1), [1], [0])])]dnl
[M4_DIVERT_ONCE(_INIT_, [kldstat -q -m g_part || gpart load], [_INIT_GPART])]dnl
[M4_FOREACH([_GPT_DEVICE], [$1],
[define([_GPT_INDEX], [0])]dnl
[M4_DIVERT_TEXT(_FORMAT_,
[gpart destroy -F _GPT_DEVICE() || :]
[gpart create -s gpt _GPT_DEVICE()]
[M4_JOIN([
], shift(shift($@)))])]dnl
[define([_GPT_SUFFIX], incr(defn([_GPT_SUFFIX])))])]dnl
[popdef([_GPT_INDEX], [_GPT_PREFIX], [_GPT_SUFFIX])])


# CWAL_GPT_PART(<SYMBOL>, <LABEL>, <TYPE>, [SIZE])
#
define([CWAL_GPT_PART],
[ifdef([_GPT_DEVICE],, [M4_FATAL([$0: must be used within CWAL_GPT macro])])]dnl
[M4_IFBLANK([$2], [M4_FATAL([$0: non-empty argument required for label])])]dnl
[M4_IFBLANK([$3], [M4_FATAL([$0: non-empty argument required for type])])]dnl
[define([_GPT_INDEX], incr(defn([_GPT_INDEX])))]dnl
[M4_IFBLANK([$1],, [define([$1]_GPT_SUFFIX(), _GPT_DEVICE()p[]_GPT_INDEX())])]dnl
[gpart add -i _GPT_INDEX() -a 1M -t $3 M4_IFBLANK([$4],, [-s $4 ])-l _GPT_PREFIX()$2[]_GPT_SUFFIX() _GPT_DEVICE()])


# CWAL_GPT_EFI(<SYMBOL>, <LABEL>, [SIZE])
# Add an EFI system partition and embed bootstrap code.
#
define([CWAL_GPT_EFI],
[CWAL_GPT_PART([$1], [$2], [efi], [ifelse([$3],, [512M], [$3])])[]]dnl
[M4_DIVERT_TEXT(_CONFIG_,
[gpart bootcode -p CWAL_CHROOTDIR([/boot/boot1.efifat]) -i _GPT_INDEX() _GPT_DEVICE()])])

# CWAL_GPT_BIOS(<SYMBOL>, <LABEL>, [SIZE])
# Add a BIOS boot partition and embed bootstrap code.
#
define([CWAL_GPT_BIOS], [_CWAL_GPT_BIOS([gptboot], $@)])
define([CWAL_GPT_BIOS_ZFS], [_CWAL_GPT_BIOS([gptzfsboot], $@)])
define([_CWAL_GPT_BIOS],
[CWAL_GPT_PART([$2], [$3], [freebsd-boot], [ifelse([$4],, [512K], [$4])])[]]dnl
[M4_DIVERT_TEXT(_CONFIG_,
[gpart bootcode -b CWAL_CHROOTDIR([/boot/pmbr]) -p CWAL_CHROOTDIR([/boot/$1]) -i _GPT_INDEX() _GPT_DEVICE()])])


# CWAL_GMIRROR(<SYMBOL>, <LABEL>, <DEVICES...>)
# Create a gmirror(8) device named LABEL from the specified DEVICES.
# Assign the mirrored device identifier to SYMBOL.
#
define([CWAL_GMIRROR],
[M4_IFBLANK([$2], [M4_FATAL([$0: non-empty argument required for label])])]dnl
[ifelse(eval([($#) < 3]), [1], [M4_FATAL([$0: one or more providers required])])]dnl
[M4_IFBLANK([$1],, [define([$1], [mirror/$2])])]dnl
[M4_DIVERT_ONCE(_INIT_, [kldstat -q -m g_mirror || gmirror load], [_INIT_GMIRROR])]dnl
[M4_DIVERT_TEXT(_FORMAT_, [gmirror label -h $2 M4_JOIN([ ], shift(shift($@)))])])


# CWAL_GSTRIPE(<SYMBOL>, <LABEL>, <DEVICES...>)
# Create a gstripe(8) device named LABEL from the specified DEVICES.
# Assign the striped device identifier to SYMBOL.
#
define([CWAL_GSTRIPE],
[M4_IFBLANK([$2], [M4_FATAL([$0: non-empty argument required for label])])]dnl
[ifelse(eval([($#) < 3]), [1], [M4_FATAL([$0: one or more providers required])])]dnl
[M4_IFBLANK([$1],, [define([$1], [stripe/$2])])]dnl
[M4_DIVERT_ONCE(_INIT_, [kldstat -q -m g_stripe || gstripe load], [_INIT_GSTRIPE])]dnl
[M4_DIVERT_TEXT(_FORMAT_, [gstripe label -h $2 M4_JOIN([ ], shift(shift($@)))])])


define([GELI_EALGO], [AES-XTS])
define([GELI_KEYLEN], [256])

# CWAL_GELI(<SYMBOL>, <LABEL>, <DEVICE>)
# Create a geli(8) device from the specified DEVICE.
# Assign the encrypted device identifier to SYMBOL.
#
# LABEL should be a unique prefix for keyfile names, following sysrc(8)
# variable naming restrictions.
#
define([CWAL_GELI],
[pushdef([_GELI_KEYFILE], [CWAL_WRKDIR()/geli/$2.key])]dnl
[pushdef([_GELI_METAFILE], [CWAL_WRKDIR()/geli/$2.eli])]dnl
[M4_IFBLANK([$1],, [define([$1], [$3.eli])])]dnl
[M4_DIVERT_ONCE(_INIT_, [kldstat -q -m g_eli || geli load], [_INIT_GELI])]dnl
[M4_DIVERT_TEXT(_FORMAT_,
[mkdir -p -m 0700 -- CWAL_WRKDIR()/geli]
[dd if=/dev/random of='_GELI_KEYFILE()' bs=64 count=1]
[geli init -b -e GELI_EALGO() -l GELI_KEYLEN() -s 4096 -K '_GELI_KEYFILE()' -B '_GELI_METAFILE()' $3]
[geli attach -k _GELI_KEYFILE() $3])]dnl
[M4_DIVERT_TEXT(_CONFIG_,
[install -d -o root -g wheel -m 0700 CWAL_CHROOTDIR([/boot/geli])]
[install -o root -g wheel -m 0400 '_GELI_KEYFILE()' '_GELI_METAFILE()' CWAL_CHROOTDIR([/boot/geli/])])]
[CWAL_LOADERCONF(
[aesni_load="YES"]
[geom_eli_load="YES"],
[$0])]dnl
[CWAL_LOADERCONF(
[geli_$2_keyfile0_load="YES"]
[geli_$2_keyfile0_type="CWAL_DEVNAME([$3]):geli_keyfile0"]
[geli_$2_keyfile0_name="/boot/geli/$2.key"],
[$0_$2])]dnl
[popdef([_GELI_KEYFILE], [_GELI_BACKUP])])
