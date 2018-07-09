FROM uazlibraries/nginx-shibboleth

# Change www-data uid:gid from 33:33 to archivematica's 333:333
RUN groupmod -g 333 www-data && usermod -u 333 www-data && \
rm -fv /var/log/nginx/* && \
ln -sf /dev/stdout /var/log/nginx/access.log && \
ln -sf /dev/stderr /var/log/nginx/error.log
