# Archivematica test_instance docker-compose

This  [docker-compose.yml](https://github.com/ualibraries/archivematica/blob/master/compose/test_instance/docker-compose.yml) example creates an instance of archivematica to quickly test with, where all settings and data are intended to be thrown away.

## Pre-requisites

### Email Settings

Archivematica sends emails on processing status. The docker-compose uses the following settings, which should be changed to match your organization's email setup.

* SMTP_DOMAIN=gmail.com
* SMTP_SERVER=smtp.gmail.com:587
* SMTP_FROM=dockertestfilesender@gmail.com
* ADMIN_EMAIL=amatica_admin@gmail.com

### Incoming directory

Archivematica's default directory for transferring in content to process is the /home directory within the container. This should get externally mounted to the host system in order to provide content for archivematica to process. The docker-compose file currently sets the incoming directory to a locally created ./incoming dir when the container is created

```
   volumes:
      - /home:/home
```

### Shell script

An equivalent shell script to the [docker-compose.yml](https://github.com/ualibraries/archivematica/blob/master/compose/test_instance/docker-compose.yml) file is:

```sh
  
    #!/bin/sh
    
    AMATICA_INCOMING_DIR=/home
    
    docker run -d \
           --restart=unless-stopped \
           -p 80:80 \
           -p 8000:8000 \
           -e SMTP_DOMAIN=gmail.com \
           -e SMTP_SERVER=smtp.gmail.com:587 \
           -e SMTP_FROM=dockertestfilesender@gmail.com \
           -e ADMIN_EMAIL=amatica_admin@gmail.com \
           -v $AMATICA_INCOMING_DIR:/home \
           --name amatica \
           uazlibraries/archivematica:1.6.1-beta1
  
```
