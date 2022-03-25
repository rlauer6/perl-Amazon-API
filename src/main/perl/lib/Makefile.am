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

APISTUBMODULES = \
    Amazon/API/CloudWatchLogs.pm.in \
    Amazon/API/EC2.pm.in \
    Amazon/API/ECS.pm.in \
    Amazon/API/SecretsManager.pm.in \
    Amazon/API/SQS.pm.in \
    Amazon/API/SSM.pm.in

APIMODULES = \
    Amazon/API/Error.pm.in \
    Amazon/API/Signature4.pm.in

GPERLMODULES = $(PERLMODULES:.pm.in=.pm)
GAPIMODULES = $(APIMODULES:.pm.in=.pm)
GAPISTUBMODULES = $(APISTUBMODULES:.pm.in=.pm)

amazon_DATA = $(GPERLMODULES)
amazon_api_DATA = \
    $(GAPIMODULES) \
    $(GAPISTUBMODULES)

dist_noinst_DATA = \
    $(PERLMODULES) \
    $(APIMODULES) \
    $(APISTUBMODULES)

GALLMODULES = \
   $(GPERLMODULES) \
   $(GAPIMODULES) \
   $(GAPISTUBMODULES)

POD2MAN = /usr/bin/pod2man

G3MANPAGES = $(GALLMODULES:.pm=.3man)

AUTOMAKE_OPTIONS = -Wno-portability

man3_MANS = $(G3MANPAGES)

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
include perl-build.inc

$(GAPIMODULES): % : %.in
include perl-build.inc

$(GAPISTUBMODULES): % : %.in
include perl-build.inc

all:

$(G3MANPAGES): %.3man : %.pm
	set -x; \
	target_name="$@"; \
	echo $$target_name; \
	tname=$$(echo "$${target_name}" | sed -e 's/\.3man$$//') ;\
	"$(POD2MAN)"  \
	--center="$(PACKAGE)" \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=3man $< "$${target_name}" || touch "$${target_name}"

.PHONY: clean-local
clean-local:
	$(MAKE) clean-generated-man-pages
	find . -name '*.log' -exec rm {} \; || true

.PHONY: clean-generated-man-pages
clean-generated-man-pages:
	for f in *.3man; do \
	  echo "$$f"; \
	  rm -f "$$f" ;\
	done

install-data-hook:
	for a in $(G3MANPAGES); do \
	  target_name=$$(echo "$$a" | sed -e 's/\//::/g'); \
	  mv $(DESTDIR)$(mandir)/man3/$$(basename $$a) \
	     $(DESTDIR)$(mandir)/man3/$${target_name}; \
	done

uninstall-local:
	for a in $(G3MANPAGES); do \
	  target_name=$$(echo "$$a" | sed -e 's/\//::/g'); \
	  rm -f $(DESTDIR)$(mandir)/man3/$${target_name}; \
	done

CLEANFILES = \
    $(GPERLMODULES) \
    $(GAPIMODULES) \
    $(G3MANPAGES)

