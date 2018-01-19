# archivematica-docker
Archivematica in a self-contained docker image

This docker image was built from archivematica's installation [instructions](https://www.archivematica.org/en/docs/archivematica-1.6/admin-manual/installation/installation/)

CHArchivematica is a complex piece of software, and to create a container that will keep state across upgrades, the following docker container creation command is recommended:

```
#!/bin/sh
AMATICA_INCOMING_DIR=/mnt/archivematica-dev-home
AMATICA_ELASTIC_DIR=/var/lib/elasticsearch
AMATICA_PROCESS_DIR=/var/archivematica
AMATICA_MYSQL_DIR=/var/lib/mysql
AMATICA_LOG_DIR=/var/log/archivematica

if [ "`id archivematica 2>/dev/null`" = "" ]; then
  sudo groupadd archivematica --gid 333
  sudo useradd archivematica --uid 333 --gid 333 --create-home --home "$AMATICA_PROCESS_DIR" --shell /bin/false
fi

if [ "`id mysql 2>/dev/null`" = "" ]; then
  sudo groupadd mysql --gid 332
  sudo useradd mysql --uid 332 --gid 332 --create-home --home "$AMATICA_MYSQL_DIR" --shell /bin/false
fi

if [ "`id elasticsearch 2>/dev/null`" = "" ]; then
  sudo groupadd elasticsearch --gid 328
  sudo useradd elasticsearch --uid 328 --gid 328 --create-home --home "$AMATICA_ELASTIC_DIR" --shell /bin/false
fi

docker run -d \
       --restart=unless-stopped \
       --net=host \
       -e SMTP_DOMAIN=abcd.edu \
       -e SMTP_HOST=smtp.abcd.edu \
       -e SMTP_FROM=archivematica-admin@abcd.edu \
       -e SMTP_ADMIN=admin@abcd.edu \
       -v $AMATICA_INCOMING_DIR:/home \
       -v $AMATICA_ELASTIC_DIR:/var/lib/elasticsearch \
       -v $AMATICA_PROCESS_DIR:/var/archivematica \
       -v $AMATICA_MYSQL_DIR:/var/lib/mysql \
       -v $AMATICA_LOG_DIR:/var/log \
       --name amatica \
       uazlibraries/archivematica:1.6.1

```



