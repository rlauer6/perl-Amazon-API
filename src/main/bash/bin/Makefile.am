SUBDIRS = . 

NO_ECHO ?= @

perlrun        = @PERL@
bashrun        = @BASHRUN@
scandeps       = @SCANDEPS@
make_cpan_dist = @MAKE_CPAN_DIST@

BASHSCRIPTS = \
    amazon-api.sh.in \
    create-service.sh.in

GBASHSCRIPTS = $(BASHSCRIPTS:.sh.in=.sh)

bin_SCRIPTS = $(GBASHSCRIPTS:.sh=) build-boto-services

libexec_SCRIPTS = $(GBASHSCRIPTS)

all: $(bin_SCRIPTS)

build-boto-services:
	create-modulino.pl -i $(builddir) -m Amazon::API::Botocore::Services -a $@

dist_noinst_DATA = $(BASHSCRIPTS)

@do_subst_command@

$(GBASHSCRIPTS): % : %.in
	$(NO_ECHO)$(do_subst) $< > $@

amazon-api: amazon-api.sh
	$(NO_ECHO)cp $< $@; \
	chmod +x $@

create-service: create-service.sh
	$(NO_ECHO)cp $< $@; \
	chmod +x $@

CLEANFILES = $(GBASHSCRIPTS) $(bin_SCRIPTS)
