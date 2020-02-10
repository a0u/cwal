# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2019-2020 Albert Ou <aou@eecs.berkeley.edu>

define([AWS_REGION], [us-west-2])
define([AWS_ZONE], [us-west-2b])
define([AMI_FREEBSD_12_1], [ami-05c3afd6554d42483])
define([AMI_DEBIAN_10], [ami-04146bb094b66105c])

# EC2_CMD(<SUBCMD>, <ARGS>...)
#
define([EC2_CMD],
[aws ifdef([AWS_REGION], [--region 'AWS_REGION()' ])]dnl
[ec2 [$1] ]dnl
[M4_JOIN([ ], shift(shift($@)))])

# EC2_QUERY(<SUBCMD>, <QUERY>, <ARGS>...)
#
define([EC2_QUERY],
[aws --output text ifdef([AWS_REGION], [--region 'AWS_REGION()' ])]dnl
[M4_IFBLANK([$2],,--query [$2] )]dnl
[ec2 [$1] ]dnl
[M4_JOIN([ ], shift(shift($@)))])

# EC2_VAR(<TAG>, <CMD>)
# Hoist command substitution into a shell variable for readability and
# return the parameter expansion form.
#
define([EC2_VAR],
[M4_DIVERT_TEXT([1], [_ec2_$1="$($2)"])]dnl
[${_ec2_$1}])

# EC2_VAR_ID(<TAG>, <EC2_QUERY_ARGS>...)
# Assign the query result to a shell variable and return the parameter
# expansion form.
# <TAG> must match the prefix of the resource ID.
#
define([EC2_VAR_ID],
[pushdef([_VAR], [_ec2_$1])]dnl
[M4_DIVERT_TEXT([1],
[_VAR()="$(EC2_QUERY(shift($@)))" && test "${_VAR()}" != "${_VAR()#$1-}"])]dnl
[${_VAR()}]dnl
[popdef([_VAR])])


# EC2_SUBNET(<NAME>)
# Set subnet by name.
#
define([EC2_SUBNET],
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for subnet name])])]dnl
[define([_EC2_VAR_SUBNET],
[EC2_VAR_ID([subnet],
[describe-subnets],
['Subnets[[0]].SubnetId'],
[--filters 'Name=tag:Name,Values="[$1]"'])])])
undefine([_EC2_VAR_SUBNET])


# EC2_SECGROUP(<NAME>)
# Set security group by name.
#
define([EC2_SECGROUP],
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for security group name])])]dnl
[define([_EC2_VAR_SECGROUP],
[EC2_VAR_ID([sg],
[describe-security-groups],
['SecurityGroups[[0]].GroupId'],
[--filters 'Name=group-name,Values="[$1]"'])])])
undefine([_EC2_VAR_SECGROUP])


# EC2_VOL_ROOT([SIZE])
# Modify block device mapping for the root volume.
#
define([EC2_VOL_ROOT],
[ifdef([_EC2_AMI],, [M4_FATAL([$0: must be used within EC2_INSTANCE macro])])]dnl
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for size])])]dnl
[{\"DeviceName\":\"EC2_VAR([rootdev],
[EC2_QUERY([describe-images],
	['Images[[0]].BlockDeviceMappings[[0]].DeviceName'],
	[--filters 'Name=image-id,Values="_EC2_AMI()"'])]dnl
)\",\"Ebs\":{\"VolumeSize\":[$1]}}])

# EC2_VOL_BLANK(<DEV>, <SIZE>, [TYPE])
# Create block device mapping for a blank volume.
#
define([EC2_VOL_BLANK],
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for device name])])]dnl
[M4_IFBLANK([$2], [M4_FATAL([$0: non-empty argument required for size])])]dnl
[{\"DeviceName\":\"$1\",\"Ebs\":{\"DeleteOnTermination\":false,\"VolumeSize\":$2,]dnl
[\"VolumeType\":\"M4_IFBLANK([$3], [gp2], [$3])\",\"Encrypted\":true}}])

# EC2_BLKDEVMAP(<ENTRY>...)
# Concatenate block device mappings.
#
define([EC2_BLKDEVMAP],
["M4_LQUOTE()M4_JOIN([,], $@)M4_RQUOTE()"])


# EC2_INSTANCE(<NAME>, <TYPE>, <AMI>, <KEYPAIR>, [BLKDEVMAP], [IPADDR])
# Launch a new EC2 instance.
#
define([EC2_INSTANCE],
[M4_IFBLANK([$1], [M4_FATAL([$0: non-empty argument required for name])])]dnl
[M4_IFBLANK([$2], [M4_FATAL([$0: non-empty argument required for type])])]dnl
[M4_IFBLANK([$3], [M4_FATAL([$0: non-empty argument required for AMI ID])])]dnl
[M4_IFBLANK([$4], [M4_FATAL([$0: non-empty argument required for keypair])])]dnl
[pushdef([_EC2_AMI], [$3])]dnl
[M4_DIVERT_TEXT([2],
[EC2_CMD([run-instances],,
	[--dry-run],
	[--count 1],
	[--instance-type '[$2]'],
	[--image-id '[$3]'],
	[--key-name [$4]],
	[--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value="$1"}]'],
	[ifdef([_EC2_VAR_SUBNET], [--subnet-id "_EC2_VAR_SUBNET()"])],
	[ifdef([_EC2_VAR_SECGROUP], [--security-group-ids "_EC2_VAR_SECGROUP()"])],
	[M4_IFBLANK([$5],, [--block-device-mappings $5])]dnl
	[M4_IFBLANK([$6],, [--private-ip-address '$6'])]dnl
)])]dnl
[popdef([_EC2_AMI])])
