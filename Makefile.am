SUBDIRS = . src cpan

ACLOCAL_AMFLAGS = -I autotools

API_PM = src/main/perl/lib/Amazon/API.pm

$(API_PM):
	cd ${builddir}/src/main/perl/lib; \
	$(MAKE)

README.md: $(API_PM)
	pod2markdown < $< >$@

dist_noinst_DATA = \
    NEWS.md \
    README.md \
    ${PACKAGE_NAME}.spec \
    ${PACKAGE_NAME}.spec.in

.PHONY: cpan
cpan:
	cd . && $(MAKE)
	cd cpan && $(MAKE) cpan

DISTCHECK_CONFIGURE_FLAGS = --enable-distcheck-hack --enable-rpmbuild

CLEANFILES = README.md
