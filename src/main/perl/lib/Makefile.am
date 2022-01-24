SUBDIRS = .

perlrun = @PERL@

if RPMBUILD_ENABLED
perlwc = \#
else
perlwc = @PERL@ -wc
endif

perl5libdir = @perl5libdir@
ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@

# this is where we will install these perl modules
amazondir = @perl5libdir@/Amazon
amazon_apidir = $(amazondir)/API

PERLMODULES = \
    Amazon/API.pm.in

APIMODULES = \
    Amazon/API/Error.pm.in \
    Amazon/API/Signature4.pm.in

GPERLMODULES = $(PERLMODULES:.pm.in=.pm)
GAPIMODULES = $(APIMODULES:.pm.in=.pm)

amazon_DATA = $(GPERLMODULES)
amazon_api_DATA = $(GAPIMODULES)

dist_noinst_DATA = $(PERLMODULES) $(APIMODULES)

@do_subst_command@

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

# Please see the notes concerning PERLINCLUDE in the ../bin/Makefile.am file
PERLINCLUDE = \
   -I $(builddir) \
   $(PERL5_EXTRA_INCLUDES) \
   -I $(perl5libdir) 

$(GPERLMODULES): % : %.in  $(GAPIMODULES)
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	PERLINCLUDE="$(PERLINCLUDE)"; \
	test -n "$$PERL5LIB" && PERLINCLUDE="$$PERLINCLUDE -I $$PERL5LIB"; \
	echo $(perlwc) $$PERLINCLUDE  $@ || { ret=$$?; rm $@ && exit $$ret; }

$(GAPIMODULES): % : %.in 
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	PERLINCLUDE="$(PERLINCLUDE)"; \
	test -n "$$PERL5LIB" && PERLINCLUDE="$$PERLINCLUDE -I $$PERL5LIB"; \
	echo $(perlwc) $$PERLINCLUDE  $@ || { ret=$$?; rm $@ && exit $$ret; }
all:

CLEANFILES = \
    $(GPERLMODULES) \
    $(GAPIMODULES)
