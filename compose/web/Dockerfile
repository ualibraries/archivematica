FROM nginx:stable

ENV FILESENDER_V=1.6.1 SSP_V=1.14.12

# Make apt-get commands temporarily non-interactive
# Solution from https://github.com/phusion/baseimage-docker/issues/58
# Update apt cache to use fastest local mirror
RUN apt-get update && DEBIAN_FRONTEND=noninteractive && \
apt-get install -y netcat curl mariadb-client openssl
    
RUN cd /opt && \
    curl -kL https://downloads.filesender.org/filesender-${FILESENDER_V}.tar.gz | tar xz && \
    curl -L https://github.com/simplesamlphp/simplesamlphp/releases/download/v${SSP_V}/simplesamlphp-${SSP_V}.tar.gz | tar xz

RUN rm -r /etc/nginx/conf.d/default.conf 

ADD docker-entrypoint.sh /usr/local/bin/entrypoint.sh
ADD conf/ /opt/conf.d

RUN mkdir /opt/conf.d/cert && \
    cd /opt/conf.d/cert && \
    openssl req -subj '/CN=Test/O=Test/C=LT' -newkey rsa:2048 -new -x509 -days 3652 -nodes -out saml.crt -keyout saml.pem

VOLUME ["/opt/filesender", "/opt/simplesamlphp"]

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 80 443
