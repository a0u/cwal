CWAL_BEGIN([gentoo])

CWAL_GPT([/dev/sda], [HOST()-],
	[CWAL_GPT_SAVE([.gpt])],
	[CWAL_GPT_PART([DEV_SWAP], [swap], [GPT_TYPE_SWAP()], [1G])],
	[CWAL_GPT_PART([DEV_ROOT], [root], [GPT_TYPE_LUKS()], [384G])])

CWAL_LUKS([DEV_LUKS], [root], [DEV_ROOT()])

CWAL_SWAP([DEV_SWAP()], [swap])

CWAL_BTRFS([vault], [DEV_LUKS()],
	[CWAL_BTRFS_OPTIONS([defaults],[noatime],[compress=lzo],[ssd],[autodefrag])],
	[CWAL_BTRFS_SUBVOL([])],
	[CWAL_BTRFS_SUBVOL([boot])],
	[CWAL_BTRFS_SUBVOL([usr])],
	[CWAL_BTRFS_SUBVOL([var])],
	[CWAL_BTRFS_SUBVOL([home])],
	[CWAL_BTRFS_SUBVOL([tmp])],
	[CWAL_BTRFS_SUBVOL([opt])])

dnl Use existing EFI system partition
CWAL_ESP([/dev/sda1])

CWAL_TMPFS([/tmp], [defaults,nodev,nosuid,mode=1777])
CWAL_TMPFS([/var/tmp/portage], [defaults,nodev,nosuid,uid=portage,gid=portage,mode=0755])

CWAL_KERNEL([src/gentoo/config-5.10.11-gentoo-C226WS])

CWAL_SYSTEMDBOOT([crypt_root=UUID=CWAL_UUID([DEV_ROOT()]) root_trim=yes root=UUID=CWAL_UUID([DEV_LUKS()]) rootflags=subvol=@ rw])

CWAL_END()
