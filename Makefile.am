SUBDIRS = . src cpan

ACLOCAL_AMFLAGS = -I autotools

POD2MARKDOWN = @POD2MARKDOWN@

src/main/perl/lib/README.md:
	cd src/main/perl/lib
	$(MAKE)

README.md: src/main/perl/lib/README.md
	cp $< $@

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
