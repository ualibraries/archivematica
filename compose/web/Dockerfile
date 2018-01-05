FROM nginx:stable

ENV FILESENDER_V=1.6.1 SSP_V=1.14.12

# Make apt-get commands temporarily non-interactive
# Solution from https://github.com/phusion/baseimage-docker/issues/58
# Update apt cache to use fastest local mirror
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive && \
apt-get install -y man netcat wget curl mariadb-client openssl nano less git sudo procps

RUN cd /opt && \
    curl -kL https://downloads.filesender.org/filesender-${FILESENDER_V}.tar.gz | tar xz && \
    curl -L https://github.com/simplesamlphp/simplesamlphp/releases/download/v${SSP_V}/simplesamlphp-${SSP_V}.tar.gz | tar xz

RUN rm -r /etc/nginx/conf.d/default.conf 
COPY conf/nginx-root.conf /etc/nginx/nginx.conf

ADD docker-entrypoint.sh /usr/local/bin/entrypoint.sh
ADD conf/ /opt/conf.d

RUN mkdir /opt/conf.d/cert && \
    cd /opt/conf.d/cert && \
    openssl req -subj '/CN=Test/O=Test/C=LT' -newkey rsa:2048 -new -x509 -days 3652 -nodes -out saml.crt -keyout saml.pem

# Build nginx shibboleth modules, taken from
# https://github.com/ConsortiumGARR/idem-tutorials/blob/master/idem-community/HOWTO-Shibboleth/Service-Provider/Debian/HOW%20TO%20SETUP%20A%20SHIBBOLETH%20SP%20WITH%20NGINX.md
RUN mkdir -p /root/nginx-modules/deb
WORKDIR /root/nginx-modules
ADD http://hg.nginx.org/pkg-oss/archive/tip.tar.gz tip.tar.gz
RUN tar -xvf tip.tar.gz && mv pkg-oss-* pkg-oss/
RUN git clone https://github.com/openresty/headers-more-nginx-module.git
RUN git clone https://github.com/nginx-shib/nginx-http-shibboleth.git
RUN pkg-oss/build_module.sh -y -o /root/nginx-modules/deb/ -n shibboleth -v `nginx -v 2>&1 | sed -n -e 's|^.*/||p' | tr -d '\n'` nginx-http-shibboleth/
RUN pkg-oss/build_module.sh -y -o /root/nginx-modules/deb/ -n headers-more -v `nginx -v 2>&1 | sed -n -e 's|^.*/||p' | tr -d '\n'` headers-more-nginx-module
RUN rm -f deb/*-dbg_*.deb && dpkg -i deb/*.deb

WORKDIR /

# Create _shibd uid.gid before package install so we can control the numeric value of uid:gid
RUN \
groupadd _shibd --gid 799 && \
useradd _shibd --uid 799 --gid 799 \
--home /var/log/shibboleth --shell /bin/false

# Enable directory colors:
RUN \
sed -i "s/^# export LS/export LS/g" /root/.bashrc && \
sed -i "s/^# eval/eval/g" /root/.bashrc && \
sed -i "s/^# alias l/alias l/g" /root/.bashrc

# Fix bash error with enabling colors:
ENV SHELL=/bin/bash

# Cleanout files & packages used to build nginx modules
#RUN apt-get purge -y build-essential && apt-get autoremove -y && apt-get clean

VOLUME ["/opt/filesender", "/opt/simplesamlphp"]

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 80 443
