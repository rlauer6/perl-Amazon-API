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

GALLMODULES = \
   $(GPERLMODULES) \
   $(GAPIMODULES)

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
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	PERLINCLUDE="$(PERLINCLUDE)"; \
	if test -n "$$PERL5LIB"; then \
	  PERLINCLUDE="$$PERLINCLUDE -I $$PERL5LIB"; \
	fi; \
	$(perlwc) $$PERLINCLUDE  $@ || { ret=$$?; rm $@ && exit $$ret; }

$(GAPIMODULES): % : %.in 
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	PERLINCLUDE="$(PERLINCLUDE)"; \
	if test -n "$$PERL5LIB"; then \
	  PERLINCLUDE="$$PERLINCLUDE -I $$PERL5LIB"; \
	fi; \
	$(perlwc) $$PERLINCLUDE $@ || { ret=$$?; rm $@ && exit $$ret; }
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

