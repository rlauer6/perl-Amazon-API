SUBDIRS = .

SHELL := /bin/bash

.SHELLFLAGS := -ec

PACKAGE_VERSION = $(shell cat $(top_srcdir)/VERSION)

PERL5LIBDIR = $(top_builddir)/src/main/perl/lib

PERLSCRIPTS = 

GPERLSCRIPTS = $(PERLSCRIPTS:.pl.in=.pl)

all: $(GPERLSCRIPTS)

.PHONY: version
version:
	echo $(VERSION);

$(GPERLSCRIPTS): % : %.in
	sed -e 's/[@]PACKAGE_VERSION[@]/$(PACKAGE_VERSION)/' $< > $@; \
	perl -wc -I $(PERL5LIBDIR) $@ || { rm $@ && exit 1; }
	test -e $@ && chmod +x $@

CLEANFILES = $(GPERLSCRIPTS)
