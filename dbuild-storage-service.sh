#!/bin/bash
set -x

DEFAULT_CONTAINER="amatica"

CONTAINER=${4:-$DEFAULT_CONTAINER}
REPOSITORY=${3:-archivematica}
TAG=${2:-storage-service-1.7.1}
ACTION=${1:-BUILD}
DAEMONIZE=-d
BUILDPATH="compose/overlay/src/archivematica-storage-service"
DOCKERFILE="$BUILDPATH/Dockerfile"

# Delete test container built from docker file
docker stop $CONTAINER
docker rm $CONTAINER

if [ "$ACTION" = "BUILD" ]; then
# Delete test image built from docker file
docker image rm $REPOSITORY:$TAG

# Create test image from docker file
docker build --rm=true -t $REPOSITORY:$TAG -f ${DOCKERFILE} ${BUILDPATH} || exit 1

ACTION=DEBUG

fi

if [ "$ACTION" = "DEBUG" ]; then
    DAEMONIZE=""
    DEBUG="--user root -it --entrypoint /bin/bash"
fi

if [ "$ACTION" = "INSTALL" ]; then

HOSTLOG=/tmp/log
NETWORK="private-network"

docker run $DAEMONIZE $DEBUG \
       --net=$NETWORK \
       -p 80:80 \
       -p 443:443 \
       -p 8001:8001 \
       --name $CONTAINER \
       $REPOSITORY:$TAG

#       --read-only \
#       --tmpfs /tmp/ \
#       --tmpfs /var/cache/nginx:mode=755,noexec,nodev,nosuid \

else

#       -e CHOWN_ELASTICSEARCH=320:320 \
#       -e CHOWN_ELASTICSEARCH=320:320 \
    
    docker run $DAEMONIZE $DEBUG \
       --net=compose_default \
       -p 80:80 \
       -p 8000:8000 \
       -e SMTP_DOMAIN=email.arizona.edu \
       -e SMTP_HOST=smtpgate.mail.arizona.edu \
       -e SMTP_FROM=admin@email.arizona.edu \
       -e SMTP_ADMIN=glbrimhall@email.arizona.edu \
       --link compose_db-host_1:db-host \
       --name $CONTAINER \
       $REPOSITORY:$TAG

#       -v /etc/shibboleth:/etc/shibboleth \
#       -p 9090:9090 \

fi
