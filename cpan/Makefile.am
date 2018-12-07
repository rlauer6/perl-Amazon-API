SUBDIRS = .

CPAN_DIST_MAKER=/usr/local/libexec/make-cpan-dist.pl

cpan: buildspec.yml
	$(CPAN_DIST_MAKER) -b $<

.PHONEY: cpan

clean-local:
	rm -f *.tar.gz
