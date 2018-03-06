#!/bin/sh
#set -x

ACTION=${1:-restart}
SMTP_DOMAIN=${SMTP_DOMAIN:-abcd.edu}
SMTP_FROM=${SMTP_FROM:-archivematica@$SMTP_DOMAIN}
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@$SMTP_DOMAIN}
export SENDMAIL_ENDPOINTS="-F 'Archivematica' -f $SMTP_FROM $ADMIN_EMAIL"

service_check () {
  SERVICE_GREP=${2:-$1}
  if [ "`echo $AMATICA_NOSERVICE | grep -i $SERVICE_GREP`" = "" ]; then
    service $1 $ACTION
  fi
}

#Check to see if this is the first time the container is ran
export SETUP_DIR="/usr/share/archivematica/docker"
export SETUP_LOG="/var/log/archivematica/setup-archivematica.log"

if [ ! -f "$SETUP_DIR/setup-launched" ]; then
  touch "$SETUP_DIR/setup-launched"
  cd $SETUP_DIR && ./setup-log-archivematica.sh
fi

service_check postfix

# mysql requires docker aufs instead of the now default overlay2 which does
# not provide provide all necessary mysql IO features, see 
# https://github.com/docker/for-linux/issues/72
service_check mysql

service_check elasticsearch

if [ "`echo $AMATICA_NOSERVICE | grep -i clam`" = "" ]; then
  if [ "$ACTION" = "start" ] || [ "$ACTION" = "restart" ]; then
    freshclam
  fi
fi

service_check clamav-daemon clam
service_check gearman-job-server gearman
service_check archivematica-mcp-server server
service_check archivematica-mcp-client client
service_check archivematica-storage-server storage
service_check archivematica-dashboard dashboard
service_check nginx
service_check archivematica-fits fits

if [ "`echo $AMATICA_NOSERVICE | grep -i mail`" = "" ]; then
  cat $SETUP_DIR/startup-complete.txt | sendmail $SENDMAIL_ENDPOINTS
fi

if [ "$2" = "FOREGROUND" ]; then
  while [ $? -eq "0" ]; do
    sleep 10
    ps -ef | grep gearman | grep -v grep > /dev/null
  done
fi
