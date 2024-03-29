CWAL_BEGIN([aws])

EC2_SUBNET([SI])
EC2_INSTANCE([HARVEST], [m5.xlarge], AMI_FREEBSD_13(), [SI],
	[EC2_BLKDEVMAP(
		[EC2_VOL_ROOT([16])],
		[EC2_VOL_BLANK([/dev/sdf], [32])])],
	[172.16.2.5])

CWAL_END()
