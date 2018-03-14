# Archivematica-docker

- [Introduction](#introduction)
- [Packaging Strategy](#packaging)
- [Dependencies](#dependencies)
- [Environment Variables](#environment-variables)
- [Logging](#logging)
- [Deployment use cases](#deployment-use-cases)

## Introduction

Archivematica in a self-contained docker image

This docker image was built from archivematica's installation [instructions](https://www.archivematica.org/en/docs/archivematica-1.6/admin-manual/installation/installation/)

The 1.6 release of archivematica was not designed from the ground up to integrate with docker like the up-n-coming [1.7 release](https://github.com/artefactual-labs/am/blob/master/compose/README.md), so this docker container instance does not follow the standard practice of having multiple docker containers all interconnected, each containing a single service. Instead most of the archivematica services are installed and running within a single container, though the container can exclude services from running via configuration if they are hosted externally, such as mysql.

This release has a [docker-compose example](https://github.com/ualibraries/archivematica/tree/1.6.1-beta3/compose/shibboleth) integrating with shibboleth to provide only security protection. The up-n-coming 1.7 release has some [examples](https://github.com/JiscRDSS/rdss-archivematica) of full shibboleth integration where user attributes are used in addition to the security protection.

## Packaging

Archivematica is a complex piece of software, and to create an all-in-one self-contained container the following packaging strategies were used:

### Two stage installation

Archivematica creates database tables, pulls latest anti-virus rules, ie a number of tasks which require running instances of databases, which isn't possible when creating a docker image using a Dockerfile.

This requires taking a two stage installation approach.

The first stage, happening within the Dockerfile, accomplishes:

1. Creation of required system users such as 'archivematica', 'nginx', 'mysql' so the uid:gid are well defined, and can be easily changed during docker creation to fit existing deployment setups. This also allows clean definition of docker volumes for root directories of these services.
2. Install all pre-requisites used by the archivematica packages, including latest python pip installed libraries.
3. Download, but not install, archivematica packages.

The second stage, happening the first time an archivematica docker container instance is ran, accomplishes:

1. Change uid:gid values of system users per CHOWN_<USER>=uid:gid environment variables via the script [chown-archivematica.sh](https://github.com/ualibraries/archivematica/blob/master/docker/chown-archivematica.sh). Within the container, the script is located at /usr/share/archivematica/docker/chown-archivematica.sh.
2. Installation of mysql, elasticsearch, archivematica-storage, archivematica-server, archivematica-client, archivematica-dashboard through the script [setup-archivematica.sh](https://github.com/ualibraries/archivematica/blob/master/docker/setup-archivematica.sh). Within the container, the script is located at /usr/share/archivematica/docker/setup-archivematica.sh.
3. Email the sysadmin when the second stage is complete, with a log of second stage installtion through the script [setup-log-archivematica.sh](https://github.com/ualibraries/archivematica/blob/master/docker/setup-log-archivematica.sh). Within the container, the script is located at /usr/share/archivematica/docker/setup-log-archivematica.sh.
4. Startup each of the services through the script [entrypoint-archivematica.sh](https://github.com/ualibraries/archivematica/blob/master/docker/service-archivematica.sh). Within the container, the script is located at /entrypoint-archivematica.sh.

## Dependencies
This docker image of filesender requires the following environment dependencies:

### Host system dependencies
1. [docker-compose](https://docs.docker.com/compose/overview/) is installed on the system.
2. The host system's time synchronized with a master [ntp](https://en.wikipedia.org/wiki/Network_Time_Protocol) server.
3. No other service on the system is listening at port 80 or 443. This can be changed through modifying the docker-compose configuration and files.
4. A public IP address if using shibboleth authentication. For production deployments, having nginx using an ssl cert associated with a public DNS entry is the ideal situation.
5. For production deployments, planned disk capacity for both uploaded files and the storage capacity for processed AIPs and DIPs.

### External dependencies

1. An [smtp](https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) server to send emails. For the examples located in the [compose/](https://github.com/ualibraries/archivematica/tree/1.6.1-beta3/compose) directory, they use a gmail test account. For a production deployment an organization's smtp server should be used.

## Docker Settings
### Environment Variables

The following environment variables control the archivematica docker container:

* CHOWN_ELASTICSEARCH - used to over-ride the default elasticsearch uid:gid value 328:328
* CHOWN_GEARMAN - used to over-ride the default gearman uid:gid value 329:329
* CHOWN_NGINX - used to over-ride the default nginx uid:gid value 330:330
* CHOWN_CLAMAV - used to over-ride the default clamav uid:gid value 331:331
* CHOWN_MYSQL - used to over-ride the default mysql uid:gid value 332:332
* CHOWN_ARCHIVEMATICA - used to over-ride the default archivematica uid:gid value 333:333
* SMTP_DOMAIN - the default email domain, for instance for email address admin@email.abcde.org the value would be 'email.abcde.org'
* SMTP_SERVER - the SMTP relayhost for sending email, for instance smtpgate.mail.abcde.org
* SMTP_FROM - the default 'from' email address when archivematica sends messages, for instance archivematica-admin@email.abcd.org
* ADMIN_EMAIL - the system administrator's email address for this instance of archivematica.
* DB_HOST - the database host to connect to. No value is necessary if using the internal mysql service.
* DB_PORT - the database port to connect to. No value is necessary if using the internal mysql service.
* DB_TYPE - the database type being used, current supported values are 'mysql' and 'postgres'. No value is necessary if using mysql internally or externally.
* DB_ADMIN - the database administrator account used to create the DB_DATABASE. No value is necessary if using the internal mysql service.
* DB_USER - the database account owning the DB_DATABASE instance of archivematica tables. No value is necessary if using the internal mysql service.
* DB_PASSWORD - the database account password. No value is necessary if using the internal mysql service.
* DB_DATABASE - the db database namespace to contain the archivematica tables. The default value is 'MCP'.
* AMATICA_DASHBOARD_LISTEN - the dashboard's gunicorn listen address. The default value is 127.0.0.1:8002. To use a unix socket, an example value would be unix:/run/archivematica/dashboard.sock
* AMATICA_STORAGE_LISTEN - the dashboard's gunicorn listen address. The default value is 127.0.0.1:8001. To use a unix socket, an example value would be unix:/run/archivematica/storage.sock
* AMATICA_OVERLAY_DIR - The directory which contains overlay archivematica source code files, which are applied after all of archivematica installation is completed. Default is /opt/archivematica.
* AMATICA_NOSERVICE - keyword list of services to not run in the archivematica docker container. Multiple services can be listed seperated by a comman with no spaces, for instance 'postfix,mysql,elasticsearch'. Available keywords:
postfix
  * mysql - the mysql server
  * elasticsearch - the elasticsearch server
  * clam - the clamav service
  * gearman - the gearman service
  * server - the archivematica mcp service
  * client - the archivematica mcp client
  * storage - the archivematica storage service
  * dashboard - the archivematica dashboard service
  * nginx - the frontend nginx service
  * fits - the fits service

These variables are set using the [setup-archivematica.sh](https://github.com/ualibraries/archivematica/blob/master/docker/setup-archivematica.sh) script, which runs the first time the starts up.

### Persistant Mount Points

Archivematica and it's dependant services have a number of directories that contain files which need to persist across upgrades for production deployments.

The following paths should be externally mounted to the filesystem, NAS, or a docker volume. Note that the service name's uid:gid is applied to all directories and files under the respective root because those services run as that uid:gid.

* /var/log - contains a number of service log files and directories. See the [logging](#logging) section for more details.
* /var/lib/elasticsearch - contains persistance data for elasticsearch
* /var/lib/gearman - contains persistance data for gearman
* /var/lib/clamav - contains persistance data for clamav
* /var/lib/mysql - contains persistance data for mysql
* /home - the archivematica "incoming" directory for content that should get transferred into the system
* /var/archivematica - the archivematica "storage" directory for content it has ingested. This includes by default the processed AIP and DIP content.

### Logging

Logging occurs under a number of subdirectories under /var/log/. Note the uid:gid permissions need to match those of the respective service logging to those dirs:

* archivematica/ - processing
* elasticsearch/ - search
* gearman/ - processing workflow
* fits/    - image-procesing
* clamav/  - anti-virus
* nginx/   - web

## Deployment use cases

This docker image has been tested under the following deployment scanarios:

1. [Throw-away self-contained test instance](https://github.com/ualibraries/archivematica/tree/1.6.1-beta4/compose/test_instance)
2. [Self-contained instance, good across upgrades](#upgradeable)
3. [External mysql](https://github.com/ualibraries/archivematica/tree/1.6.1-beta4/compose/external_mysql)
4. [External nginx](#external_nginx)
5. [Filesender integration](#filesender)

## Upgradeable

This creates an archivematica instance that will keep state across upgrades. In order to accomplish this many service directories are externalized to the host system ( or could be put into a docker volume ). To ensure uid:gid services match across the host and docker image, a number of users need to be created on the host system.

```
`#!/bin/sh
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
       -p 80:80 \
       -p 8000:8000 \
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
       uazlibraries/archivematica:1.6.1-beta2

```
