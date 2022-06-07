SUBDIRS = . src cpan

ACLOCAL_AMFLAGS = -I autotools

API_PM = src/main/perl/lib/Amazon/API.pm

POD2MARKDOWN = @POD2MARKDOWN@

$(API_PM):
	cd ${builddir}/src/main/perl/lib; \
	$(MAKE)

README.md: $(API_PM)
	$(POD2MARKDOWN) < $< >$@

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
