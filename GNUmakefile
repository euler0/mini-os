include Makefile.inc

SUBDIRS= src kernel.elf
export OBJS=

#all: build_dir

#build_dir:
#	mkdir -p build

#.PHONY: clean
#clean:

.PHONY: subdirs $(SUBDIRS)
subdirs: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@
