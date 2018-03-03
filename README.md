rchivematica-docker

- [Introduction](#introduction)
- [Packaging Strategy](#packaging)
- [Dependencies](#dependencies)
- [Environment Variables](#environment-variables)
- [Logging](#logging)
- [Deployment use cases](#deployment-use-cases)
- [Logs](#logs)
- [Scaling](#scaling)
- [Ports](#ports)
- [Tests](#tests)
- [Cleaning up](#cleaning-up)
- [Troubleshooting](#troubleshooting)
- [Nginx returns 502 Bad Gateway](#nginx-returns-502-bad-gateway)
- [MCPClient osdeps cannot be updated](#mcpclient-osdeps-cannot-be-updated)

## Introduction

Archivematica in a self-contained docker image

This docker image was built from archivematica's installation [instructions](https://www.archivematica.org/en/docs/archivematica-1.6/admin-manual/installation/installation/)

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

1. Change uid:gid values of system users per CHOWN_<USER>=uid:gid environment variables. [ /usr/share/archivematica/docker/chown-archivematica.sh ].
2. Installation of mysql, elasticsearch, archivematica-storage, archivematica-server, archivematica-client, archivematica-dashboard [ /usr/share/archivematica/docker/setup-archivematica.sh ].
3. Email the sysadmin when the second stage is complete, with a log of second stage [ /usr/share/archivematica/docker/setup-log-archivematica.sh ].

## Dependencies
This docker image of filesender requires the following environment dependencies:

### Host system dependencies
1. [docker-compose](https://docs.docker.com/compose/overview/) is installed on the system.
2. The host system's time synchronized with a master [ntp](https://en.wikipedia.org/wiki/Network_Time_Protocol) server.
3. No other service on the system is listening at port 80 or 443. This can be changed through modifying the docker-compose configuration and files.
4. A public IP address if using shibboleth authentication. For production deployments, having nginx using an ssl cert associated with a public DNS entry is the ideal situation.
5. For production deployments, planned disk capacity for both uploaded files and the storage capacity for processed AIPs and DIPs.

### External dependencies

1. An [smtp](https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) server to send emails. For the examples located in the [compose/](https://github.com/ualibraries/filesender-phpfpm/tree/2.0-beta2/compose) directory, they use a gmail test account. For a production deployment an organization's smtp server should be used.

## Environment Variables

The following environment variables control the docker setup:

* FILESENDER_URL - full URL to enter in the browser to bring up filesender
* FILESENDER_AUTHTYPE - used by the 2.x series with the possible values:
  * shibboleth - use shibboleth for authentication
  * saml - use simplesamlphp for authentication
  * fake - use a fake user to authenticate.
* FILESENDER_AUTHSAML - when using simplesaml for authentication, which is the only option with the 1.x series, the authentication type to use as defined in simplesamlphps's [config/authsources.php](https://github.com/ualibraries/filesender-phpfpm/tree/1.6/compose/simplesaml/simplesamlphp/config) file.
* MAIL_ATTR, NAME_ATTR, UID_ATTR - depending on the value of FILESENDER_AUTHTYPE:
  * shibboleth - the fastcgi environment variable containing the attribute value.
  * simplesamlphp - the saml attribute name to use.
  * fake - the actual value to use
* DB_HOST - the database hostname to connect to.
* DB_NAME - the database namespace to install filesender tables into
* DB_USER - the database user to connecto the database system with
* DB_PASSWORD - the database user password
* SMTP_SERVER - the SMTP server to send email through. It must be a valid server for filesender to work.
* SMTP_TLS - The SMTP server requires TLS encrypted communication
* SMTP_USER - the optional user account needed to connect to the SMTP server
* SMTP_PSWD - the optional SMTP user account password
* CHOWN_WWW - An optional uid:gid value for filesender to run as. It is most relevent when docker mounting the container's /data directory to store uploads on the host filesystem. Filesender should be running as the user owning the host system directory, otherwise upload permission errors will occur.
* ADMIN_EMAIL - email address of the filesender admin account, must be valid
* ADMIN_USERS - the set of user accounts that should be considered administrators
* ADMIN_PSWD - the password to use for the admin account 
* SIMPLESAML_MODULES - the space seperated list of simplesaml [module directories](https://github.com/simplesamlphp/simplesamlphp/tree/master/modules) to enable for authentication and filtering. Usually enabling one of these modules requires setting configuration settings for it in the [authsources.php](https://github.com/ualibraries/filesender-phpfpm/tree/1.6/compose/simplesaml/simplesamlphp/config) file.
* SIMPLESAML_SALT - an optional simplesaml salt value to use. A value will get auto-generated on first time startup if missing.

These variables are set using the [setup.sh](https://github.com/ualibraries/filesender-phpfpm/blob/2.0-beta2/docker/setup.sh) script, which runs in the filesender-phpfpm docker container the first time it starts up from the location /setup.sh.

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

1. [Throw-away self-contained test instance](#test-instance).
2. [Self-contained instance, good across upgrades](#upgradeable)
3. [External mysql](#external_mysql)
4. [External nginx](#external_nginx)
5. [Filesender integration](#filesender)

## Test Instance

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
`#!/bin/sh

AMATICA_INCOMING_DIR=/mnt/archivematica-dev-home

docker run -d \
       --restart=unless-stopped \
       -p 80:80 \
       -p 8000:8000 \
       -e SMTP_DOMAIN=abcd.edu \
       -e SMTP_HOST=smtp.abcd.edu \
       -e SMTP_FROM=archivematica-admin@abcd.edu \
       -e SMTP_ADMIN=admin@abcd.edu \
       -v $AMATICA_INCOMING_DIR:/home \
       --name amatica \
       uazlibraries/archivematica:1.6.1-beta1

```

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
