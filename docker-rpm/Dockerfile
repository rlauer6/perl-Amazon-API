FROM amazonlinux:2

COPY package.lst .
RUN yum install -y $(cat package.lst)

RUN curl -L https://cpanmin.us | perl - App::cpanminus
RUN cpanm -v -n Pod::Markdown

COPY rpm-build /usr/bin/rpm-build

RUN chmod +x /usr/bin/rpm-build
