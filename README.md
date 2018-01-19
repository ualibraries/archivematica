# archivematica-docker
Archivematica in a self-contained docker image

This docker image was built from archivematica's installation [instructions](https://www.archivematica.org/en/docs/archivematica-1.6/admin-manual/installation/installation/)

## Packaging strategies

Archivematica is a complex piece of software, and to create an all-in-one self-contained container the following packaging strategies were used:

### Two stage installation

Archivematica creates database tables, pulls latest anti-virus rules, ie a number of tasks which require running instances of databases, which isn't possible when creating a docker image using a Dockerfile.

This requires taking a two stage installation approach.

The first stage, happening within the Dockerfile, accomplishes:

1. Creation of required system users such as 'archivematica', 'nginx', 'mysql' so the uid:gid are well defined, and can be easily changed during docker creation to fit existing deployment setups. This also allows clean definition of docker volumes for root directories of these services.
2. Install all pre-requisites used by the archivematica packages, including latest python pip installed libraries.
3. Download, but not install, archivematica packages.

The second stage, happening the first time an archivematica docker container instance is ran, accomplishes:

1. Change uid:gid values of system users per CHOWN_<USER>=uid:gid environment variables. [ /usr/share/archivematica/docker/chown-archivematica.sh ].
2. Installation of mysql, elasticsearch, archivematica-storage, archivematica-server, archivematica-client, archivematica-dashboard [ /usr/share/archivematica/docker/setup-archivematica.sh ].
3. Email the sysadmin when the second stage is complete, with a log of second stage [ /usr/share/archivematica/docker/setup-log-archivematica.sh ].

### Logging

Logging occurs under a number of subdirectories under /var/log/:

archivematica/ - processing
elasticsearch/ - search
gearman/ - processing workflow
fits/    - image-procesing
clamav/  - anti-virus
nginx/   - web


## Deployment use cases

This release is still considered beta because only the following deployment use cases have been tested:

1. [Throw-away self-contained test instance](#throw-away-test).
2. [Self-contained instance, good across upgrades](#self-contained-upgradeable)


## Throw away test

This example quickly creates an archivematica instance to test with. Any processed content/logs/state will get erased if the docker container is recreated.

### Pre-requisites

#### Email Settings

SMTP_DOMAIN=abcd.edu
SMTP_HOST=smtp.abcd.edu
SMTP_FROM=archivematica-admin@abcd.edu
SMTP_ADMIN=admin@abcd.edu

#### Host directories

AMATICA_INCOMING_DIR=/home

```
#!/bin/sh

AMATICA_INCOMING_DIR=/mnt/archivematica-dev-home

docker run -d \
       --restart=unless-stopped \
       --net=host \
       -e SMTP_DOMAIN=abcd.edu \
       -e SMTP_HOST=smtp.abcd.edu \
       -e SMTP_FROM=archivematica-admin@abcd.edu \
       -e SMTP_ADMIN=admin@abcd.edu \
       -v $AMATICA_INCOMING_DIR:/home \
       --name amatica \
       uazlibraries/archivematica:1.6.1-beta1

```

## Self contained upgradeable

Archivematica is a complex piece of software, and to create a container that will keep state across upgrades, the following docker container creation command is recommended:

```
#!/bin/sh
AMATICA_INCOMING_DIR=/mnt/archivematica-dev-home
AMATICA_ELASTIC_DIR=/var/lib/elasticsearch
AMATICA_PROCESS_DIR=/var/archivematica
AMATICA_MYSQL_DIR=/var/lib/mysql
AMATICA_LOG_DIR=/var/log/archivematica

if [ "`id archivematica 2>/dev/null`" = "" ]; then
  sudo groupadd archivematica --gid 333
  sudo useradd archivematica --uid 333 --gid 333 --create-home --home /var/archivematica --shell /bin/false
fi

if [ "`id mysql 2>/dev/null`" = "" ]; then
  sudo groupadd mysql --gid 332
  sudo useradd mysql --uid 332 --gid 332 --create-home --home /var/lib/mysql --shell /bin/false
fi

if [ "`id elasticsearch 2>/dev/null`" = "" ]; then
  sudo groupadd elasticsearch --gid 328
  sudo useradd elasticsearch --uid 328 --gid 328 --create-home --home /var/lib/elasticsearch --shell /bin/false
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
       uazlibraries/archivematica:1.6.1-beta1

```



