SUBDIRS = . 

perlrun        = @PERL@
bashrun        = @BASHRUN@
scandeps       = @SCANDEPS@
make_cpan_dist = @MAKE_CPAN_DIST@

BASHSCRIPTS = \
    amazon-api.sh.in \
    create-service.sh.in

GBASHSCRIPTS = $(BASHSCRIPTS:.sh.in=.sh)
bin_SCRIPTS = $(GBASHSCRIPTS:.sh=)

libexec_SCRIPTS = $(GBASHSCRIPTS)
dist_noinst_DATA = $(BASHSCRIPTS)

@do_subst_command@

$(GBASHSCRIPTS): % : %.in
	$(do_subst) $< > $@

amazon-api: amazon-api.sh
	cp $< $@
	chmod +x $@

create-service: create-service.sh
	cp $< $@
	chmod +x $@

CLEANFILES = $(GBASHSCRIPTS) $(bin_SCRIPTS)
