# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (C) 2019 Albert Ou <aou@eecs.berkeley.edu>

M4 ?= m4

hosts :=

objs := $(hosts:%=build/%)

.PHONY: all
all: $(objs)

build/%: lib/cwal.m4 hosts/%.m4
	@mkdir -p $(dir $@)
	$(M4) -D HOST=$(notdir $@) $^ > $@
	chmod +x $@

.PHONY: clean
clean:
	rm -f -- $(objs)
