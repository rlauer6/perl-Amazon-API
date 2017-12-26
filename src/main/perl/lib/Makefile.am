SUBDIRS = .

perlrun = @PERL@

if RPM_BUILD_MODE
perlwc = \#
else
perlwc = @PERL@ -wc
endif

perl5libdir = @perl5libdir@
ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@

# this is where we will install these perl modules
amazondir = @datadir@/perl5/Amazon
amazon_apidir = @datadir@/perl5/Amazon/API

logdir = @localstatedir@/log

PERLMODULES = \
    Amazon/API.pm.in

APIMODULES = \
    Amazon/API/Error.pm.in

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
	$(perlwc) $(PERLINCLUDE)  $@ || { ret=$?; rm $@ && exit $ret; }

$(GAPIMODULES): % : %.in 
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) $(PERLINCLUDE)  $@ || { ret=$?; rm $@ && exit $ret; }
all:

CLEANFILES = \
    $(GPERLMODULES) \
    $(GAPIMODULES)
