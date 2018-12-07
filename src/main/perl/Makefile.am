SUBDIRS = . lib

check_SCRIPTS = prove.sh
TESTS = $(check_SCRIPTS)

test:
	prove -v -r -I lib -I @perl5libdir@ t

prove.sh:
	echo 'prove -r -I lib -I @perl5libdir@ t' > prove.sh
	chmod 755 prove.sh

CLEANFILES = $(check_SCRIPTS)
