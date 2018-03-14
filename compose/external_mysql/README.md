# Archivematica external_mysql docker-compose

This  [docker-compose](https://github.com/ualibraries/archivematica/blob/master/compose/external_mysql/docker-compose.yml) example creates an instance of archivematica where the [mysql](https://hub.docker.com/_/mysql/) service is running externally in it's own docker container, rather than within archivematica's container

The central configuration element that forces the use of an external database is:

* AMATICA_NOSERVICE=mysql,logfile

The **mysql** setting causes the internal mysql server to not run within the archivematica container. The **logfile** setting causes archivematica's initial startup to be output to the docker logging framework so the 5-10 minute initial startup can be watched.

Other necessary configuration elements within the [docker-compose](https://github.com/ualibraries/archivematica/blob/master/compose/external_mysql/docker-compose.yml) that are needed because mysql is running externally:

* DB_HOST=db-host - specifies the docker link name to the mysql container
* DB_USER=filesender -  the mysql dba user to connect with
* DB_PASSWORD=filesender - the mysql dba password to connect with
* DB_DATABASE=MCP - the mysql database schema space name

