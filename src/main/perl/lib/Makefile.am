SUBDIRS = .

include directories.inc
include modules.inc

perlrun = @PERL@
POD2MAN = @POD2MAN@

if RPMBUILD_ENABLED
perlwc = \#
else
perlwc = @PERL@ -wc
endif

@do_subst_command@

ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@

GAMAZON_PERLMODULES                     = $(AMAZON_PERLMODULES:.pm.in=.pm)
GAMAZON_API_PERLMODULES                 = $(AMAZON_API_PERLMODULES:.pm.in=.pm)
GAMAZON_API_POD_PERLMODULES             = $(AMAZON_API_POD_PERLMODULES:.pm.in=.pm)
GAMAZON_API_POD_SIMPLE_PERLMODULES      = $(AMAZON_API_POD_SIMPLE_PERLMODULES:.pm.in=.pm)
GAMAZON_API_BOTOCORE_PERLMODULES        = $(AMAZON_API_BOTOCORE_PERLMODULES:.pm.in=.pm)
GAMAZON_API_BOTOCORE_SHAPE_PERLMODULES  = $(AMAZON_API_BOTOCORE_SHAPE_PERLMODULES:.pm.in=.pm)

G3MANPAGES = $(GALLMODULES:.pm=.3man)

AUTOMAKE_OPTIONS = -Wno-portability

man3_MANS = $(G3MANPAGES)

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

# Please see the notes concerning PERLINCLUDE in the ../bin/Makefile.am file
PERLINCLUDE = \
   -I $(builddir) \
   $(PERL5_EXTRA_INCLUDES) \
   -I $(perl5libdir) 

%.pm: %.pm.in
include perl-build.inc

$(GAMAZON_PERLMODULES): % : %.in \
    Amazon/API/Constants.pm \
    Amazon/API/Error.pm \
    Amazon/API/Signature4.pm \
    Amazon/API/Template.pm \
    Amazon/API/Botocore.pm \
    Amazon/API/Botocore/Shape.pm \
    Amazon/API/Botocore/Shape/Serializer.pm

Amazon/API/Botocore/Shape.pm: % : %.in \
    Amazon/API/Template.pm \
    Amazon/API/Botocore/Shape/Utils.pm

Amazon/API/Botocore.pm: % : %.in \
    Amazon/API/Botocore/Shape.pm \
    $(GAMAZON_API_POD_PERLMODULES)

$(GAMAZON_API_PERLMODULES): % : %.in $(GAMAZON_API_BOTOCORE_PERLMODULES)  

# $(GAMAZON_API_BOTOCORE_PERLMODULES): % : %.in $(GAMAZON_API_PERLMODULES)

$(GAMAZON_API_POD_PERLMODULES): % : %.in $(GAMAZON_API_POD_SIMPLE_PERLMODULES)

Amazon/API/Botocore.pm: % : %.in

$(GAMAZON_API_BOTOCORE_SHAPE_PERLMODULES): % : %.in  \
    Amazon/API/Constants.pm \
    Amazon/API/Template.pm

README.md: Amazon/API.pm
	$(POD2MARKDOWN) < $< >$@

amazon_DATA = \
    $(GAMAZON_PERLMODULES)

amazon_api_DATA = \
    $(GAMAZON_API_PERLMODULES) \
    Amazon/API/Constants.pm \
    Amazon/API/Error.pm \
    Amazon/API/Signature4.pm \
    Amazon/API/Template.pm

amazon_api_botocore_shape_DATA = \
    $(GAMAZON_API_BOTOCORE_SHAPE_PERLMODULES)

amazon_api_botocore_DATA = \
    $(GAMAZON_API_BOTOCORE_PERLMODULES) \
    Amazon/API/Botocore/Shape.pm

amazon_api_pod_DATA = \
    $(GAMAZON_API_POD_PERLMODULES)

amazon_api_pod_simple_DATA = \
    $(GAMAZON_API_POD_SIMPLE_PERLMODULES)

dist_noinst_DATA = \
    Amazon/API/Constants.pm.in \
    Amazon/API/Error.pm.in \
    Amazon/API/Signature4.pm.in \
    Amazon/API/Template.pm.in \
    Amazon/API/Botocore/Shape.pm.in \
    $(AMAZON_PERLMODULES) \
    $(AMAZON_PERLMODULES) \
    $(AMAZON_API_PERLMODULES) \
    $(AMAZON_API_POD_PERLMODULES) \
    $(AMAZON_API_POD_SIMPLE_PERLMODULES) \
    $(AMAZON_API_BOTOCORE_PERLMODULES) \
    $(AMAZON_API_BOTOCORE_SHAPE_PERLMODULES)

all: README.md

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

CRITIC_REPORTS=$(GALLMODULES:.pm=.pc)

check: $(GALLMODULES) $(CRITIC_REPORTS)

%.pc: %.pm
	VERBOSE="--verbose $${VERBOSE:-8}"; \
	set -e;set -o pipefail; \
	if ! perlcritic -1 $< $$VERBOSE | tee $@; then \
	  mv $@ perlcritic.log; \
	  false; \
	fi

.PHONY: clean-local
clean-local:
	find . -name '*.log' -exec rm {} \; || true
	find . -name '*.pc' -exec rm {} \; || true
	$(MAKE) clean-generated-man-pages

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
    Amazon/API/Constants.pm \
    Amazon/API/Error.pm \
    Amazon/API/Signature4.pm \
    Amazon/API/Template.pm \
    Amazon/API/Botocore/Shape.pm \
    $(GAMAZON_PERLMODULES) \
    $(GAMAZON_API_PERLMODULES) \
    $(GAMAZON_API_POD_PERLMODULES) \
    $(GAMAZON_API_POD_SIMPLE_PERLMODULES) \
    $(GAMAZON_API_BOTOCORE_PERLMODULES) \
    $(GAMAZON_API_BOTOCORE_SHAPE_PERLMODULES) \
    $(G3MANPAGES)
