# -*- mode: gnumakefile; -*-

all:
	docker build -f Dockerfile . -t rpmbuilder

rpm:
	mkdir -p /tmp/scratch
	docker run --rm -v /tmp/scratch:/scratch rpmbuilder \
	   /usr/bin/rpm-build https://github.com/rlauer6/perl-Amazon-API
	ls -alrt /tmp/scratch/*.rpm
