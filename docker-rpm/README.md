# README

This is the README file for building an rpm for `perl-Amazon-API`.

In this directory you will find a Dockerfile for creating a Docker
container that can be used to build an rpm for the `Amazon::API` perl module.

# Requirements

* `docker`

# Building the Container

```
docker build -f Dockerfile.rpm-build . -t rpmbuilder
```

# Building the RPM

Mount some directory to `/scratch` and run the `rpm-build` utility in
the container. The result will be an rpm you can use to install
`Amazon::API`

```
mkdir scratch
docker run --rm -v scratch:/scratch rpmbuilder \
   /usr/bin/rpm-build https://github.com/rlauer6/perl-Amazon-API

ls -alrt scratch
```

