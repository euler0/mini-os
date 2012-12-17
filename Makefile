include Makefile.inc

SUBDIRS= src

#all: build_dir

#build_dir:
#	mkdir -p build

#.PHONY: clean
#clean:

.PHONY: subdirs $(SUBDIRS)
subdirs: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@
