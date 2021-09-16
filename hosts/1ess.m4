CWAL_BEGIN([aws])

EC2_SUBNET([SI])
EC2_SECGROUP([SI:irc])
EC2_INSTANCE([1ESS], [t3.nano], AMI_FREEBSD_13(), [SI],
	[EC2_BLKDEVMAP(
		[EC2_VOL_BLANK([/dev/sdf], [4])])],
	[172.16.2.4])

CWAL_END()
