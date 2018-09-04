define([_INIT_], [1])
define([_FORMAT_], [2])
define([_INSTALL_], [3])
define([_CONFIG_], [4])
define([_FSTAB_], [5])
define([_LOADER_], [6])

include([lib/freebsd/pre.m4])
include([lib/freebsd/geom.m4])
include([lib/freebsd/fs.m4])
include([lib/freebsd/world.m4])

define([CWAL_END],
[include([lib/freebsd/post.m4])])
