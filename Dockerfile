FROM ubuntu:14.04
MAINTAINER Amer Grgic "amer@tevreden.nl"

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=C.UTF-8 LANGUAGE=en_US.UTF-8

# Add files needed for bulding
ADD ./dist.ini dist.ini
ADD ./chartdirector /chartdirector
ADD ./wkhtml2pdf /wkhtml2pdf

# Create Jenkins user
RUN useradd jenkins

# Install first dependencies
RUN apt-get update && apt-get install -y openssh-client git build-essential

# Install dependencies
RUN sudo apt-get install -y cpanminus libssl-dev libexpat1-dev libgd-perl libgmp3-dev libapache2-mod-perl2 libmysqlclient-dev xfonts-base xfonts-75dpi libxrender1 fontconfig

# Create directories
RUN mkdir -p /usr/include/apache2 /usr/local/lib/site_perl
RUN mkdir -p /var/log/evaluation && sudo chown jenkins:jenkins /var/log/evaluation

# Install CPAN modules
RUN cpanm --no-skip-satisfied -n Class::Method::Modifiers YAML::XS
RUN cpanm --no-skip-satisfied -n JSTOWE/TermReadKey-2.32.tar.gz CPAN::Uploader || { cat ~/.cpanm/build.log ; false ; } ;
RUN cpanm --no-skip-satisfied -n Dist::Zilla

RUN dzil authordeps --missing | sudo cpanm --no-skip-satisfied -n
RUN dzil listdeps --author --missing | sudo cpanm --no-skip-satisfied -n

# Install ChartDirector
RUN sudo tar -jxf /chartdirector/chartdir.tar.bz2 -C/usr/local/lib/site_perl

RUN dpkg -s wkhtmltox 2>/dev/null >/dev/null || sudo dpkg -i /wkhtml2pdf/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb