FROM uazlibraries/nginx-shibboleth:latest

ENV FILESENDER_V=2.0-beta2 SSP_V=1.15.0

RUN \
cd /opt && \
curl -kL https://github.com/filesender/filesender/archive/filesender-$FILESENDER_V.tar.gz | tar xz && \
mv filesender-filesender-$FILESENDER_V filesender-$FILESENDER_V && \
curl -L https://github.com/simplesamlphp/simplesamlphp/releases/download/v${SSP_V}/simplesamlphp-${SSP_V}.tar.gz | tar xz

ADD docker-entrypoint.sh /usr/local/bin/entrypoint.sh
ADD conf/ /opt/conf.d

VOLUME ["/opt/filesender", "/opt/simplesamlphp"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 80 443
