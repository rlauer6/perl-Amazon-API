SUBDIRS = . 

perlrun = @PERL@
bashrun = @BASHRUN@

BASHSCRIPTS = \
    amazon-api.sh.in

GBASHSCRIPTS = $(BASHSCRIPTS:.sh.in=.sh)
bin_SCRIPTS = $(GBASHSCRIPTS:.sh=)

libexec_SCRIPTS = $(GBASHSCRIPTS)
dist_noinst_DATA = $(BASHSCRIPTS)

@do_subst_command@

$(GBASHSCRIPTS): % : %.in
	$(do_subst) $< > $@

amazon-api: $(GBASHSCRIPTS)
	cp $< $@
	chmod +x $@

CLEANFILES = $(GBASHSCRIPTS) $(bin_SCRIPTS)
