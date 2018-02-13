#!/bin/sh

echo " * Archivematica Setup Beginning..."

if [ "`echo $AMATICA_NOSERVICE | grep -i logfile`" != "" ]; then
  ln -sf /dev/stdout "$SETUP_LOG"
fi

# Create setup log header that will get mailed
cat <<EOF  > "$SETUP_LOG"
Subject: Archivematica setup is finished.

EOF

# Run and time the main setup script
time -o "$SETUP_LOG" -a ./setup-archivematica.sh >> "$SETUP_LOG" 2>&1

if [ "`echo $AMATICA_NOSERVICE | grep -i logfile`" = "" ]; then

  # Email the setup log
  cat "$SETUP_LOG" | sendmail $SENDMAIL_ENDPOINTS

else

LOGFILES="\
gearman-job-server/gearman.log \
elasticsearch/elasticsearch.log \
clamav/clamav.log \
clamav/freshclam.log \
fits-ngserver/archivematica-fits.log \
nginx/access.log \
archivematica/MCPServer/MCPServer.log \
archivematica/MCPServer/MCPServer.debug.log \
archivematica/setup-archivematica.log \
archivematica/storage-service/gunicorn.access_log \
archivematica/storage-service/storage_service.log \
archivematica/storage-service/storage_service_debug.log \
archivematica/dashboard/dashboard.debug.log \
archivematica/dashboard/gunicorn.access_log \
archivematica/dashboard/dashboard.log \
archivematica/MCPClient/MCPClient.debug.log \
archivematica/MCPClient/MCPClient.log \
archivematica/MCPClient/client_scripts.log"

ERRFILES="\
archivematica/dashboard/gunicorn.error_log \
archivematica/storage-service/gunicorn.error_log \
nginx/access.log \
mysql/error.log"
    
  for FILE in $LOGFILES; do
      rm -f "/var/log/$FILE"
      ln -sf /dev/stdout "/var/log/$FILE"
  done
  
  for FILE in $ERRFILES; do
      rm -f "/var/log/$FILE"
      ln -sf /dev/stderr "/var/log/$FILE"
  done
fi

echo " * Archivematica Setup Finished."
