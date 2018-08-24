# Archivematica-docker

- [Introduction](#introduction)
- [Packaging Strategy](#packaging)
- [Dependencies](#dependencies)
- [Environment Variables](#environment-variables)
- [Logging](#logging)
- [Deployment use cases](#deployment-use-cases)

## Introduction

Archivematica built from artifactual docker images. This [1.7.x series](https://github.com/artefactual-labs/am/blob/master/compose/README.md) was designed from the ground up to work with docker - each service has it's own container.

This release has a full [docker-compose example](https://github.com/ualibraries/archivematica/tree/1.7.1/compose/shibboleth) integration with shibboleth where its user attributes are used in addition to the security protection.

## Packaging

Archivematica is a complex piece of software. Since the 1.7.x or higher is designed to work with docker, the goal of the packaging is to add services in a complementary manner above and beyond what is provided by artefactual.

This is accomplished through [docker-compose override](https://docs.docker.com/compose/extends/) functionality. In addition, Artefactual does not provide docker images of archivematica release branches, so four archivematica service docker images are created from release branches: mcp-server, mcp-client, dashboard, and storage-service.

## Dependencies
This docker image of archivematica requires the following environment dependencies:

### Host system dependencies
1. [docker-compose](https://docs.docker.com/compose/overview/) is installed on the system.
2. The host system's time synchronized with a master [ntp](https://en.wikipedia.org/wiki/Network_Time_Protocol) server.
3. No other service on the system is listening at port 80 or 443. This can be changed through modifying the docker-compose configuration and files. If installing on a cloud system, then the ports 80 and 443 need to be opened up.
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
