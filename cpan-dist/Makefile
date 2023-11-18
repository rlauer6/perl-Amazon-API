# -*- mode: makefile-gmake; -*-
# make SERVICE=service-name

CPAN_DIST_MAKER=/usr/local/bin/make-cpan-dist.pl

cpan: buildspec.yml api
	@service=$$(cat service); \
	module_name=$$(cat module); \
	test -n "$$DEBUG" && set -x; \
	test -n "$$DEBUG" && DEBUG="--debug"; \
	test -e requires && REQUIRES="-r requires"; \
	test -n "$(NOCLEANUP)" && NOCLEANUP="--no-cleanup"; \
	test -n "$(DRYRUN)" && DRYRUN="--dryrun"; \
	test -n "$(SCANDEPS)" && SCANDEPS="-s"; \
	test -n "$(NOVERSION)" && NOVERSION="-n"; \
	REAL_PATH=$$(realpath .); \
	PROJECT_ROOT="--project-root $$REAL_PATH"; \
	$(CPAN_DIST_MAKER) $$PROJECT_ROOT $$REQUIRES $$DRYRUN $$SCANDEPS $$NOVERSION $$NOCLEANUP $$DEBUG -b $< || echo "$$?"; \
	$(MAKE) clean

api: $(BOTOCORE)
	@if ! test -d "./lib"; then \
	  mkdir lib; \
	fi

	@boto_service=$$(cat service); \
	module_name=$$(cat module); \
	set -e; \
	for a in stub shapes; do \
	  echo "creating...$$a"; \
	  amazon-api -b $$(pwd) -s $$boto_service -m $$module_name -o lib create-$$a; \
	done

service: service-listing.json
	@if test -n "$(SERVICE)"; then \
	  echo "$(SERVICE)" | tr [A-Z] [a-z] > $@; \
	elif test -n "$(MODULE_NAME)"; then \
	  echo "$(MODULE_NAME)" | tr [A-Z] [a-z] > $@; \
	else \
	  echo "ERROR: usage: make MODULE_NAME=module or SERVICE=service"; \
	  false; \
	fi
	service=$$(cat $@); \
	if test -z $$(find botocore/botocore/data -type d -name $$service 2>/dev/null); then \
	  >&2 echo "ERROR: no such service $$service"; \
	  rm -f $@ module; \
	  false; \
	fi

define script
require Text::ASCIITable;

my $s = <>;

$s = JSON::PP->new->decode($s);

my $t = Text::ASCIITable->new({ headingText => "Amazon Services"});

$t->setCols("Service", "Description");

foreach (sort keys %{$s}) {
 $t->addRow($_, $s->{$_});
}

print $t;
endef

export scriptlet = $(value script)

list-services: service-listing.json
	@if perl -MText::ASCIITable -e 1 2>/dev/null; then \
	  perl -MText::ASCIITable -MJSON::PP -0 -e "$$scriptlet" $<; \
	else \
	  jq --sort-keys . service-listing.json; \
	fi

service-listing.json: botocore
	@JQ=$$(command -v jq); \
	if test -z "$$JQ"; then \
	 >&2 echo "ERROR: no jq found...install jq"; \
	 false; \
	fi; \
	listing=$$(mktemp); \
	for a in $$(find botocore/botocore/data -maxdepth 1 -type d); do \
	  if [ "$$(basename $$a)" != "data" ]; then \
	    echo "$$(basename $$a),$$($$JQ -r .metadata.serviceFullName $$a/$$(ls -1 $$a | sort | tail -1)/service*)" >>$$listing; \
	  fi; \
	done; \
	perl -MJSON::PP -e 'while(<>) { chomp; ($$k,$$v) = split /,/,$$_; $$listing{$$k} = $$v; }; print JSON::PP->new->pretty->encode(\%listing);' $$listing >$@; \
	rm $$listing;

module: service
	@if test -z "$(MODULE_NAME)"; then \
	  echo "$(SERVICE)" | tr [a-z] [A-Z] > $@; \
	else \
	  echo "$(MODULE_NAME)" > $@; \
	fi

buildspec.yml: buildspec.yml.in service module
	@service=$$(cat service); \
	module_name=$$(cat module); \
	if test -z "$$service" && test -z "$$module_name"; then \
	  echo "no SERVICE or MODULE_NAME specified - make SERVICE=ecr"; \
	  false; \
	fi; \
	if test -z "$$EMAIL"; then \
	  EMAIL=$$(git config --global --get user.email); \
	fi; \
	if test -z "$$FULLNAME"; then \
	  FULLNAME=$$(git config --global --get user.name); \
	fi; \
	DATE=$$(date +%Y-%m-%d); \
	sed \
	-e "s/@date@/$$DATE/g" \
	-e "s/@service@/$$module_name/g" \
	-e "s/@email@/$$EMAIL/g" \
	-e "s/@name@/$$FULLNAME/g" $< > $@

botocore:
	@if test -n "$$BOTOCORE_PATH" && grep -q 'botocore.git' "$$BOTOCORE_PATH/.git/config"; then \
	  ln -sf $$BOTOCORE_PATH botocore; \
	else \
	   git clone https://github.com/boto/botocore.git/; \
	fi


.PHONY: cpan

CLEANFILES = \
    buildspec.yml \
    provides \
    resources \
    service \
    module

clean:
	@rm -rf lib/
	@rm -f $(CLEANFILES)
