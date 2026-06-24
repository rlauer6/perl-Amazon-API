SUBDIRS = . src

ACLOCAL_AMFLAGS = -I autotools

POD2MARKDOWN = @POD2MARKDOWN@

src/main/perl/lib/README.md:
	cd src/main/perl/lib
	$(MAKE)

README.md: src/main/perl/lib/README.md
	cp $< $@

include release-notes.mk

include version.mk

dist_noinst_DATA = \
    NEWS.md \
    README.md \
    ${PACKAGE_NAME}.spec \
    ${PACKAGE_NAME}.spec.in

cpanfile: build-requires
	tmp=$$(mktemp); \
	perl -ne 'chomp; my ($$m, $$v) = split /\s+/, $$_, 2; $$v //= "0"; print sprintf qq{requires "%s", "%s";\n}, $$m, $$v;' $< >$$tmp; \
	cp $$tmp $@; \
	rm -f $$tmp

.PHONY: cpan
cpan:
	cd . && $(MAKE)
	cd cpan && $(MAKE) cpan

DISTCHECK_CONFIGURE_FLAGS = --enable-distcheck-hack --enable-rpmbuild

CLEANFILES = README.md
