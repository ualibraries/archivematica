#
# Archivematica Dockerfile
#
# Instructions below capture instructions from:
#
# https://www.archivematica.org/en/docs/archivematica-1.6/admin-manual/installation/installation/#advanced
#

FROM uazlibraries/archivematica:1.6.1-beta1

RUN mkdir -p /etc/archivematica/archivematicaCommon

COPY docker/dbsettings /usr/share/archivematica/docker/dbsettings
COPY docker/dbconfig-common/archivematica-mcp-server.conf /usr/share/archivematica/docker/archivematica-mcp-server.conf


COPY docker/setup-archivematica.sh /usr/share/archivematica/docker/
COPY docker/setup-log-archivematica.sh /usr/share/archivematica/docker/
COPY docker/debconf-set-selections-archivematica-mcp-server.sh /usr/share/archivematica/docker/

COPY docker/service-archivematica.sh /

# Auto-start
CMD /service-archivematica.sh restart FOREGROUND
