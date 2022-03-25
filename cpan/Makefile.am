SUBDIRS = .

CPAN_DIST_MAKER=/usr/local/libexec/make-cpan-dist.pl

package_version=@PACKAGE_VERSION@
package=@PACKAGE@

# builds the distribution tarball and renames based on package version
cpan: buildspec.yml requires
	test -n "$$DEBUG" && set -x; \
	test -e requires && REQUIRES="-r requires"; \
	test -n "$(NOCLEANUP)" && NOCLEANUP="--nocleanup"; \
	test -n "$(DRYRUN)" && DRYRUN="--dryrun"; \
	test -n "$(SCANDEPS)" && SCANDEPS="-s"; \
	test -n "$(NOVERSION)" && NOVERSION="-n"; \
	$(CPAN_DIST_MAKER) $$REQUIRES $$DRYRUN $$SCANDEPS $$NOVERSION $$NOCLEANUP -b $<

# handle n.m.r-b version format (but don't use this anymore!)
	if test -n "$$(echo $(package_version) | grep '\-')"; then \
		echo $$package_version; \
		package_version=$(package_version); package=$(package); \
		tarball=$${package##perl-}-$${package_version%%-*}.tar.gz; \
		test -e "$$tarball" && mv $$tarball $${package##perl-}-$$package_version.tar.gz; \
	fi

.PHONY: cpan

CLEANFILES = \
    extra-files \
    provides \
    test-requires

clean-local:
	for a in $(CLEANFILES); do \
	  rm -f $$a || true; \
	done
	rm -f *.tar.gz
