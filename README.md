# Archivematica-docker (Archived repository)

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

Archivematica is a complex piece of software. Since the 1.7.x release or higher is designed to work with docker, the goal of the packaging is to add services in a complementary manner above and beyond what is provided by [Artefactual](https://www.artefactual.com/).

This is accomplished through [docker-compose override](https://docs.docker.com/compose/extends/) functionality. In addition, Artefactual does not provide docker images of archivematica releases, so these are created using [Dockerfiles](https://github.com/artefactual/archivematica/tree/qa/1.x/src) provided by [artefactual for developers](https://github.com/artefactual-labs/am/tree/master/compose). The following [docker images](https://hub.docker.com/r/uazlibraries/archivematica/builds/) are built: mcp-server, mcp-client, dashboard, and storage-service.

## Dependencies
This docker image of archivematica requires the following environment dependencies:

### Host system dependencies
1. [docker-compose](https://docs.docker.com/compose/overview/) is installed on the system.
2. The host system's time synchronized with a master [ntp](https://en.wikipedia.org/wiki/Network_Time_Protocol) server.
3. No other service on the system is listening at port 80 or 443. This can be changed through modifying the docker-compose configuration and files. If installing on a cloud system, ports 80 and 443 need to be opened up.
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

Archivematica 1.7+ and it's dependant services have a number of [docker volumes](https://docs.docker.com/storage/volumes/) that contain files which need to persist across upgrades for production deployments.

The following is a suggestion of paths to mount to these volumes to ensure persistance.

* am-elasticsearch-data => /var/lib/elasticsearch - contains persistance data for elasticsearch
* am-clamav-data => /var/lib/clamav - contains persistance data for clamav
* am-mysql-data => /var/lib/mysql - contains persistance data for mysql
* am-pipeline-data => /var/lib/archivematica - the archivematica "storage" directory for content it has ingested. This includes by default the processed AIP and DIP content.
* ss-location-data => /home - the archivematica "incoming" directory for content that should get transferred into the system

### Logging

All of the Archivematica 1.7 containers log to the standard docker logging facilities, so refer to documentation on [docker logging](https://docs.docker.com/config/containers/logging/) for more detail. To see the logging in real-time, go into the directory containing the docker-compose.yml file, and run the command:

```
docker-compose logs --follow

```

## Deployment use cases

This docker image has been tested under the following deployment scanarios:

1. [Shibboleth integration](#shibboleth)

## Shibboleth

This creates an archivematica instance that will keep state across upgrades and uses shibboleth attributes for login.

A script called [setup-amatica-shib.sh][https://github.com/ualibraries/archivematica/blob/1.7.1/compose/shibboleth/setup-amatica-shib.sh] is used which creates test HTTPS ssl certificates, a self-signed cert for shibboleth, the docker volumes used for persistance, and a number of other environment setups.

The script requires a public ip address for the shibboleth integration, a NAT internal IP will not work. Note you can use the public ip that your service provider has provided as long as port 80 and 443 are routed to the machine hosting the install.

To get an example up and running, use the following commands

```
git clone -b 1.7.1 git@github.com:ualibraries/archivematica.git
cd archivematica/compose/shibboleth
./setup-amatica-shib.sh <public_ip>


```

follow the testshib.org registration instructions at end of install.
