CWAL_BEGIN([freebsd])

CWAL_GPT(M4_DQUOTE([ada0]), [HOST()-],
	[CWAL_GPT_EFI([DEV_EFI], [efi], [512M])],
	[CWAL_GPT_PART([DEV_BOOT], [boot], [freebsd-ufs], [2G])],
	[CWAL_GPT_PART([DEV_SWAP], [swap], [freebsd-swap], [4G])],
	[CWAL_GPT_PART([DEV_ROOT], [root], [freebsd-zfs])])

CWAL_GELI([DEV_TANK], [crypt], [DEV_ROOT()])

CWAL_ZPOOL([tank], [DEV_TANK()],
	[CWAL_ZFS([usr])],
	[CWAL_ZFS([usr/local])],
	[CWAL_ZFS([usr/ports], [setuid=off])],
	[CWAL_ZFS([usr/ports/distfiles], [compression=off], [exec=off], [setuid=off])],
	[CWAL_ZFS([usr/ports/packages], [compression=off], [exec=off], [setuid=off])],
	[CWAL_ZFS([usr/src], [setuid=off])],
	[CWAL_ZFS([usr/obj], [compression=off])],
	[CWAL_ZFS([var])],
	[CWAL_ZFS([var/crash], [exec=off], [setuid=off])],
	[CWAL_ZFS([var/db], [compression=off], [exec=off], [setuid=off])],
	[CWAL_ZFS([var/db/pkg], [compression=lz4], [exec=on], [setuid=off])],
	[CWAL_ZFS([var/empty], [compression=off], [exec=off], [setuid=off], [readonly=on])],
	[CWAL_ZFS([var/log], [exec=off], [setuid=off])],
	[CWAL_ZFS([var/mail], [compression=gzip], [exec=off], [setuid=off])],
	[CWAL_ZFS([var/run], [compression=off], [exec=off], [setuid=off])],
	[CWAL_ZFS([var/tmp], [setuid=off])],
	[CWAL_ZFS([home], [setuid=off])],
	[CWAL_ZFS([tmp], [setuid=off])])

CWAL_SWAP_GELI([DEV_SWAP()])

CWAL_UFS([DEV_BOOT()], [/media/boot], [rw,noatime], [boot])
CWAL_NULLFS([/media/boot/boot], [/boot])

CWAL_CHMOD([1777], [/tmp], [/var/tmp])

CWAL_TMPFS([/tmp], [rw,nosuid,mode=1777,late])
CWAL_TMPFS([/usr/obj], [rw,nosuid,late])

CWAL_DISTFILES([13.0-RELEASE], [base], [kernel])

CWAL_CONSOLE_EFI()

CWAL_END()
