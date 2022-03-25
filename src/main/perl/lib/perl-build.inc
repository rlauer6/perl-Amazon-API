	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	PERLINCLUDE="$(PERLINCLUDE)"; \
	if test -n "$$PERL5LIB"; then \
	  PERLINCLUDE="$$PERLINCLUDE -I $$PERL5LIB"; \
	fi; \
	$(perlwc) $$PERLINCLUDE  $@ || { ret=$$?; rm $@ && exit $$ret; }
