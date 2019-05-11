include([lib/cwal/file.m4])

define([_INIT_], [1])
define([_FORMAT_], [2])
define([_INSTALL_], [3])
define([_KERNEL_], [4])
define([_CONFIG_], [5])
define([_FSTAB_], [6])

include([lib/gentoo/geom.m4])
include([lib/gentoo/fs.m4])
include([lib/gentoo/world.m4])

define([CWAL_END],
[include([lib/gentoo/post.m4])])
