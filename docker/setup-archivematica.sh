#!/bin/sh

# Change uid:gid permissions per CHOWN_xxxx environment variables
./chown-archivematica.sh

if [ "$SMTP_HOST" != "" ]; then
  sed -i "s/smtp.abcd.edu/$SMTP_HOST/g" ./debconf-set-selections-postfix.sh
  sed -i "s/email.abcd.edu/$SMTP_DOMAIN/g" ./debconf-set-selections-postfix.sh
fi

# gearman doesn't resolve 'localhost' within a docker container running in a private network
sed -i "s/localhost/127.0.0.1/g" /etc/default/gearman-job-server

# Make apt-get commands temporarily non-interactive
# From https://stackoverflow.com/questions/8671308/non-interactive-method-for-dpkg-reconfigure-tzdata
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

# Insert the answers for debconf interactive questions that would be asked
# when archivematica packages are installed
./debconf-set-selections-archivematica-mcp-server.sh
./debconf-set-selections-postfix.sh

# Setup archivematica with second phase post-installation
apt-get install -y mysql-server

if [ "`echo $AMATICA_NOSERVICE | grep -i mysql`" = "" ]; then
  service mysql start
else
  service mysql stop

  echo "* Waiting for external database to come online ..."

  RESULT=`echo 0`
  while [ $RESULT -ne 1 ]; do
    echo " **** Database is not responding, waiting ... **** "
    sleep 5
    RESULT=`nc -z -w1 ${DB_HOST} ${DB_PORT:-3306} && echo 1 || echo 0`
  done
fi

apt-get install -y elasticsearch

apt-get install -y archivematica-storage-service

SED_DB_USER=${DB_USER:-archivematica}
SED_DB_PASSWORD=${DB_PASSWORD:-demo}
SED_DB_DATABASE=${DB_DATABASE:-MCP}
SED_DB_HOST=${DB_HOST}
SED_DB_PORT=${DB_PORT}
SED_DB_TYPE=${DB_TYPE:-mysql}
SED_DB_ADMIN=${DB_TYPE:-root}

cat /usr/share/archivematica/docker/archivematica-mcp-server.conf | \
sed -e "s/__DB_USER__/$SED_DB_USER/g" \
    -e "s/__DB_PASSWORD__/$SED_DB_PASSWORD/g" \
    -e "s/__DB_DATABASE__/$SED_DB_DATABASE/g" \
    -e "s/__DB_HOST__/$SED_DB_HOST/g" \
    -e "s/__DB_PORT__/$SED_DB_PORT/g" \
    -e "s/__DB_TYPE__/$SED_DB_TYPE/g" \
    -e "s/__DB_ADMIN__/$SED_DB_ADMIN/g" \
> /etc/dbconfig-common/archivematica-mcp-server.conf

apt-get install -y archivematica-mcp-server

SED_DB_HOST=${DB_HOST:-localhost}

cat /usr/share/archivematica/docker/dbsettings | \
sed -e "s/__DB_USER__/$SED_DB_USER/g" \
    -e "s/__DB_PASSWORD__/$SED_DB_PASSWORD/g" \
    -e "s/__DB_DATABASE__/$SED_DB_DATABASE/g" \
    -e "s/__DB_HOST__/$SED_DB_HOST/g" \
> /etc/archivematica/archivematicaCommon/dbsettings

apt-get install -y archivematica-mcp-client
apt-get install -y archivematica-dashboard

# Per documentation at https://www.archivematica.org/en/docs/archivematica-1.6/admin-manual/installation/installation/
rm -vf /etc/nginx/sites-enabled/default
ln -vs /etc/nginx/sites-available/storage /etc/nginx/sites-enabled/storage
ln -vs /etc/nginx/sites-available/dashboard.conf /etc/nginx/sites-enabled/dashboard.conf

if [ "$DASHBOARD_LISTEN" != "" ]; then
   sed -i -e "s|127.0.0.1:8002|$DASHBOARD_LISTEN|g" \
       /etc/archivematica/dashboard.gunicorn-config.py

   if [ "`echo $DASHBOARD_LISTEN | grep ^unix`" != "" ]; then
     rm -f /etc/nginx/sites-enabled/dashboard.conf
   fi
fi

if [ "$STORAGE_LISTEN" != "" ]; then
   sed -i -e "s|127.0.0.1:8001|$STORAGE_LISTEN|g" \
       /etc/archivematica/storage-service.gunicorn-config.py

   if [ "`echo $STORAGE_LISTEN | grep ^unix`" != "" ]; then
     rm -f /etc/nginx/sites-enabled/storage
   fi
fi

# Update auto-start on bootup un-necessary with a docker container
# update-rc.d elasticsearch                defaults 95 10
# update-rc.d archivematica-storage-server defaults
# update-rc.d archivematica-mcp-server     defaults
# update-rc.d archivematica-mcp-client     defaults
# update-rc.d archivematica-dashboard      defaults
# update-rc.d archivematica-fits           defaults

# cleanup setup scripts
#rm -vf  ./debconf-set-selections-archivematica-mcp-server.sh
#rm -vf  ./debconf-set-selections-postfix.sh
#rm -vf  ./chown-archivematica.sh
#rm -vf  ./setup-archivematica.sh

service elasticsearch stop
service mysql stop
