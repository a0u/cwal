# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2019 Albert Ou <aou@eecs.berkeley.edu>

# CWAL_GPT(<DEVICES>, <PREFIX>, <BODY...>)
#
define([CWAL_GPT],
[pushdef([_GPT_PREFIX], [$2])]dnl
[pushdef([_GPT_SUFFIX],
	[ifelse(eval((M4_COUNT($1)) > 1), [1], [0])])]dnl
[M4_FOREACH([_GPT_DEVICE], [CWAL_DEVNODE([$1])],
[M4_DIVERT_TEXT(_FORMAT_,
[read _gpt_sector < '/sys/block/CWAL_DEVNAME(_GPT_DEVICE())/queue/hw_sector_size']
[_gpt_align="$(( 1048576 / _gpt_sector ))"]
[M4_JOIN([
], shift(shift($@)))]
[sleep 1])]dnl
[define([_GPT_SUFFIX], incr(defn([_GPT_SUFFIX])))])]dnl
[popdef([_GPT_PREFIX], [_GPT_SUFFIX])])

# CWAL_GPT_DESTROY()
#
define([CWAL_GPT_DESTROY],
[ifdef([_GPT_DEVICE],, [M4_FATAL([$0: must be used within CWAL_GPT macro])])]dnl
[sgdisk -Z _GPT_DEVICE()])

# CWAL_GPT_SAVE(<SUFFIX>)
# Save partition data to a backup file ending with SUFFIX.
#
define([CWAL_GPT_SAVE],
[ifdef([_GPT_DEVICE],, [M4_FATAL([$0: must be used within CWAL_GPT macro])])]dnl
[sgdisk -f CWAL_DEVNAME(_GPT_DEVICE())[]$1 _GPT_DEVICE()])

# CWAL_GPT_PART(<SYMBOL>, <LABEL>, <TYPE>, [SIZE])
#
define([CWAL_GPT_PART],
[ifdef([_GPT_DEVICE],, [M4_FATAL([$0: must be used within CWAL_GPT macro])])]dnl
[M4_IFBLANK([$2], [M4_FATAL([$0: non-empty argument required for label])])]dnl
[M4_IFBLANK([$3], [M4_FATAL([$0: non-empty argument required for type])])]dnl
[pushdef([_GPT_LABEL], [_GPT_PREFIX()$2[]_GPT_SUFFIX()])]dnl
[M4_IFBLANK([$1],, [define([$1]_GPT_SUFFIX(), [/dev/disk/by-partlabel/]_GPT_LABEL())])]dnl
[sgdisk -a "[$]{_gpt_align}" -n 0:0:M4_IFBLANK([$4],
	["$(( ( ( $(sgdisk -E _GPT_DEVICE() | tail -n 1) / _gpt_align ) * _gpt_align ) - 1 ))"],
	['+$4']) -t 0:'$3' -c 0:'_GPT_LABEL()' _GPT_DEVICE()[]]dnl
[popdef([_GPT_LABEL])])

define([GPT_TYPE_EFI], [0xEF00])
define([GPT_TYPE_SWAP], [0x8200])
define([GPT_TYPE_LINUX], [0x8300])
define([GPT_TYPE_LUKS], [CA7D7CCB-63ED-4C53-861C-1742536059CC])


define([LUKS_HASH], [sha512])
define([LUKS_CIPHER], [aes-xts-plain64])
define([LUKS_KEYSIZE], [256])

# CWAL_LUKS(<SYMBOL>, <LABEL>, <DEVICE>)
# Create an encrypted LUKS volume named LABEL from the specified DEVICE.
# Assign the device mapper identifier to SYMBOL.
#
define([CWAL_LUKS],
[define([_USE_LUKS])]dnl
[M4_IFBLANK([$2], [M4_FATAL([$0: non-empty argument required for label])])]dnl
[M4_IFBLANK([$3], [M4_FATAL([$0: non-empty argument required for device])])]dnl
[M4_IFBLANK([$1],, [define([$1], [/dev/mapper/$2])])]dnl
[M4_DIVERT_TEXT(_FORMAT_,
[cryptsetup --type luks -h LUKS_HASH() -c LUKS_CIPHER() -s LUKS_KEYSIZE() -T 3 --use-urandom luksFormat $3]
[cryptsetup open --type luks --allow-discards $3 $2])])
