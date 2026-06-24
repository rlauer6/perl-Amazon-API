########################################################################
FROM debian:trixie-slim AS builder
########################################################################

ARG RESOLVER="--resolver 02packages,https://cpan.openbedrock.net/orepan2"
ARG EXTRA_BUILD_PACKAGES=""

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        perl git libssl3 libexpat1 zlib1g ca-certificates jq \
        gcc make automake autoconf rsync \
        libssl-dev libexpat-dev zlib1g-dev libperl-dev curl && \
    curl -fsSL https://raw.githubusercontent.com/skaji/cpm/main/cpm \
        | perl - install -g App::cpm && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# clone only what we need - no full history
RUN mkdir -p /root/git && cd /root/git && \
    git clone --depth=1 https://github.com/boto/botocore.git && \
    git clone --depth=1 --branch master https://github.com/rlauer6/perl-Amazon-API.git && \
    ln -sf /root/git/botocore /root/git/perl-Amazon-API/cpan-dist/botocore

# install Perl dependencies into /usr/src/app/local
WORKDIR /usr/src/app
RUN --mount=type=cache,target=/cache/local-debian \
    cp /root/git/perl-Amazon-API/cpanfile . && \
    PERL5LIB=/cache/local-debian/lib/perl5 \
    cpm install --show-build-log-on-failure --use-install-command \
        -L /cache/local-debian ${RESOLVER} && \
    rsync -a /cache/local-debian/ /usr/src/app/local/

ENV PERL5LIB=/usr/src/app/local/lib/perl5
ENV PATH=$PATH:/usr/src/app/local/bin

# build Amazon::API core and install it
RUN cd /root/git/perl-Amazon-API && \
    ./bootstrap && \
    ./configure --with-perl5libdir=$PERL5LIB && \
    make && \
    cd cpan && make cpan && \
    cpm install --use-install-command -L /usr/src/app/local Amazon-API-*.tar.gz

########################################################################
# runtime image - no build tools, no source tree, no git history
########################################################################
FROM debian:trixie-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        perl libssl3 libexpat1 zlib1g ca-certificates jq make && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# copy only the installed Perl modules and the cpan-dist toolchain
COPY --from=builder /usr/src/app/local /usr/src/app/local
COPY --from=builder /root/git/perl-Amazon-API/cpan-dist /usr/src/app/cpan-dist
COPY --from=builder /root/git/botocore /usr/src/app/botocore

ENV PERL5LIB=/usr/src/app/local/lib/perl5
ENV PATH=$PATH:/usr/src/app/local/bin
ENV FULLNAME="aws-api-autobuild"

WORKDIR /usr/src/app/cpan-dist

# symlink botocore where the Makefile expects it
RUN ln -sf /usr/src/app/botocore botocore

# entrypoint: SERVICE and MODULE_NAME passed at runtime
# e.g. docker run --rm -v $(pwd):/output image sqs SQS
ENTRYPOINT ["/bin/bash", "-c", \
    "make SERVICE=${SERVICE} MODULE_NAME=${MODULE_NAME} && \
     cp *.tar.gz /output/"]
