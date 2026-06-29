SUBDIRS = .

SHELL := /bin/bash

.SHELLFLAGS := -ec

VERSION = $(shell cat $(top_srcdir)/VERSION)

MODULE_NAME = Amazon::API

PROJECT_NAME ?= $(shell echo $(MODULE_NAME) | sed -e 's/::/-/g;')

TARBALL = $(PROJECT_NAME)-$(VERSION).tar.gz

CPAN_DIST_MAKER=@MAKE_CPAN_DIST@

package_version=@PACKAGE_VERSION@
package=@PACKAGE@

all: $(TARBALL)

.PHONY: cpan
cpan: $(TARBALL)

$(TARBALL): buildspec.yml services.api
	cd $(top_srcdir); \
	$(MAKE)
	test -n "$$DEBUG" && set -x; \
	test -n "$$DEBUG" && DEBUG="--debug"; \
	test -e requires && REQUIRES="--requires requires"; \
	test -n "$(NOCLEANUP)" && NOCLEANUP="--no-cleanup"; \
	test -n "$(DRYRUN)" && DRYRUN="--dryrun"; \
	test -n "$(NOVERSION)" && NOVERSION="-n"; \
	PROJECT_ROOT="--project-root $$(readlink -f ..)"; \
	$(CPAN_DIST_MAKER) $$PROJECT_ROOT $$REQUIRES $$DRYRUN $$SCANDEPS $$NOVERSION $$NOCLEANUP $$DEBUG -b $< || echo "$$?"

BOTOCORE_PATH  = $(top_builddir)/cpan-dist/botocore
BOTOCORE_STATE = $(top_builddir)/.botocore.state
BOTOCORE_REPO  = https://github.com/boto/botocore.git

BUILD_BOTO_SERVICES = $(top_builddir)/src/main/bash/bin/build-boto-services

$(BUILD_BOTO_SERVICES):
	cd $(top_builddir)/src/main/bash/bin; \
	$(MAKE)

PERL5LIBDIR = $(top_builddir)/src/main/perl/lib

$(BOTOCORE_STATE): FORCE
	remote_hash=$$(git ls-remote $(BOTOCORE_REPO) HEAD | awk '{print $$1}'); \
	if [ ! -f $(BOTOCORE_STATE) ] || [ "$$remote_hash" != "$$(cat $(BOTOCORE_STATE))" ]; then \
	  echo "$$remote_hash" > $(BOTOCORE_STATE); \
	  cd $(BOTOCORE_PATH) && git pull; \
	fi

FORCE:

# The directory target handles the initial clone
$(BOTOCORE_PATH):
	mkdir -p $(top_builddir)/cpan-dist
	git clone https://github.com/boto/botocore.git $@
	cd $(top_builddir)/cpan-dist; \
	git checkout master

# services.api only runs if missing or if the botocore dir is newer
services.api: $(BOTOCORE_STATE) $(BOTOCORE_PATH) $(BUILD_BOTO_SERVICES)
	PERL5LIB=$(PERL5LIB):$(PERL5LIBDIR) $(BUILD_BOTO_SERVICES) $$LIMIT -p $(BOTOCORE_PATH) -o $@

# update-botocore now ensures the directory exists first
.PHONY: update-botocore
update-botocore: $(BOTOCORE_PATH)
	cd $(BOTOCORE_PATH) && git pull

CLEANFILES = \
    extra-files \
    provides \
    resources 

clean-local:
	for a in $(CLEANFILES); do \
	  rm -f $$a || true; \
	done
	rm -f *.tar.gz
	rm -f *.tmp
	if test -n "$$(ls -d Amazon-API-*)"; then \
	  rm -rf "$$(ls -d Amazon-API-*)"; \
	fi
