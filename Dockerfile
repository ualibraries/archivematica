#
# Archivematica Dockerfile
#
# Instructions below capture instructions from:
#
# https://www.archivematica.org/en/docs/archivematica-1.6/admin-manual/installation/installation/#advanced
#

FROM uazlibraries/archivematica:1.6.1-beta2

RUN mv /service-archivematica.sh /entrypoint-archivematica.sh && \
mkdir -p /usr/share/archivematica/dashboard && \
mkdir -p /usr/share/python/archivematica-storage-service && \
mkdir -p /run/archivematica && \
chown archivematica.archivematica /run/archivematica

COPY docker/setup-archivematica.sh /usr/share/archivematica/docker
COPY docker/setup-log-archivematica.sh /usr/share/archivematica/docker

#chown -R archivematica.archivematica /usr/share/archivematica/dashboard && \
#chown -R archivematica.archivematica /usr/lib/archivematica/storage-service

#VOLUME [ "/var/lib/elasticsearch", "/var/lib/gearman", "/var/lib/clamav", "/var/lib/mysql", "/var/log", "/usr/share/archivematica/dashboard", "/usr/share/python/archivematica-storage-service", "/run/archivematica" ]

EXPOSE 80 443 8000 8001 8002

# Auto-start
CMD /entrypoint-archivematica.sh start FOREGROUND
