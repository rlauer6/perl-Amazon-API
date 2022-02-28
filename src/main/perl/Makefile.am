SUBDIRS = lib .

UNIT_TESTS = \
    t/00-load.t \
    t/amazon-api.t

check_SCRIPTS = prove.sh

TESTS = \
   $(check_SCRIPTS)

test:
	prove -v -r -I lib -I @perl5libdir@ t

prove.sh:
	echo "#!/bin/bash" >$@
	echo "ls -l t; prove -r -I lib -I @perl5libdir@ $(srcdir)/t" >>$@
	chmod 755 prove.sh
	./prove.sh

dist_noinst_DATA = \
    $(UNIT_TESTS)

CLEANFILES = $(check_SCRIPTS)
