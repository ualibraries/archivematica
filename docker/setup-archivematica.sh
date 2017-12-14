#!/bin/sh

# Change uid:gid permissions per CHOWN_xxxx environment variables
./chown-archivematica.sh

if [ "$SMTP_HOST" != "" ]; then
  sed -i "s/smtp.abcd.edu/$SMTP_HOST/g" ./debconf-set-selections-postfix.sh
  sed -i "s/email.abcd.edu/$SMTP_DOMAIN/g" ./debconf-set-selections-postfix.sh
fi

# Make apt-get commands temporarily non-interactive
# From https://stackoverflow.com/questions/8671308/non-interactive-method-for-dpkg-reconfigure-tzdata
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

# Insert the answers for debconf interactive questions that would be asked
# when archivematica packages are installed
./debconf-set-selections-archivematica-mcp-server.sh
./debconf-set-selections-postfix.sh

# Setup archivematica with second phase post-installation
apt-get install -y mysql-server
/etc/init.d/mysql start
apt-get install -y elasticsearch
apt-get install -y archivematica-storage-service
apt-get install -y archivematica-mcp-server
apt-get install -y archivematica-mcp-client
apt-get install -y archivematica-dashboard

# Per documentation at https://www.archivematica.org/en/docs/archivematica-1.6/admin-manual/installation/installation/
rm -vf /etc/nginx/sites-enabled/default
ln -vs /etc/nginx/sites-available/storage /etc/nginx/sites-enabled/storage
ln -vs /etc/nginx/sites-available/dashboard.conf /etc/nginx/sites-enabled/dashboard.conf

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
