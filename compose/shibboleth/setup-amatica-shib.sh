#!/bin/bash
#set -x

REQUIRED="hostname perl sed openssl docker-compose nc curl id /usr/sbin/addgroup /usr/sbin/adduser"

for UTILITY in $REQUIRED; do
  WHICH_CMD="`which $UTILITY`"

  if [ "$WHICH_CMD" = "" ]; then
    echo "ERROR: please install cmd line utility: $UTILITY"
    echo "ERROR: $REQUIRED are needed."  
    exit 1
  fi
done

# Make sure we are running from the setup-amatica-shib.sh directory
SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
while [ ! -d "$SETUP_DIR/../shibboleth/template" ]; do
    SETUP_DIR="$( cd $SETUP_DIR/.. && pwd )"
done

echo "SETUP_DIR: $SETUP_DIR"
cd $SETUP_DIR

GIVENIP=$1
HOSTIP=$1
PERSISTANT_DIR=${2:-$SETUP_DIR/persistant}
RUN_MODE=$3
UPGRADE_MODE=""

if [ "$GIVENIP" = "cleanup" ] || [ "$RUN_MODE" = "cleanup" ]; then
  docker-compose rm -fsv
  docker volume prune -f
  docker volume rm am-clamav-data am-elasticsearch-data am-mysql-data am-pipeline-data ss-location-data
  exit 0
fi

# Shibboleth attributes to use
SHIB_UID=${SHIB_UID:-\$shib_eppn}
SHIB_LNAME=${SHIB_LNAME:-\'LastName\'}
SHIB_FNAME=${SHIB_FNAME:-\'FirstName\'}
SHIB_CNAME=${SHIB_CNAME:-\'FirstName LastName\'}
SHIB_MAIL=${SHIB_MAIL:-\$shib_eppn}

if [ "$HOSTIP" = "" ]; then
  HOSTIP=`hostname -I 2>&1 | perl -ne '@ip = grep( !/^(192.168|10|172.[1-3]\d)./, split(/\s/)); print join("|",@ip)'`

OCTETS=`echo -n $HOSTIP | sed -e 's|\.|#|g' | perl -ne '@valid = grep(/\d+/,split(/#/)); print scalar(@valid)'`

echo "CALCULATED $HOSTIP has $OCTETS parts"

# Validate 
if [ "$OCTETS" != "4" ]; then
   echo "ERROR: was not able to use a single IP to setup with."
   echo "ERROR: Please rerun passing in the public IP to use."
   echo "ERROR: Example: ./setup-amatica-shib.sh <your_public_ip>"
   exit 1
fi
fi

#function create_persistant_dirs {

# Ensure archivematica users exist
#USER_LIST="_shibd elasticsearch gearman nginx clamav mysql archivematica"
#USER_ID=799
#USER_INC=0
#
#for USER in $USER_LIST; do
#  #sudo deluser --remove-home $USER
#  if [ "`id $USER 2>/dev/null`" = "" ]; then
#    echo "CREATEUSER: $USER with uid:gid $USER_ID:$USER_ID"
#    sudo addgroup $USER --force-badname --gid $USER_ID
#    sudo adduser --system $USER --force-badname --uid $USER_ID --gid $USER_ID --home /var/lib/$USER --shell /bin/false
#  fi
#  if [ ! -d "$PERSISTANT_DIR/$USER" ]; then
#    mkdir -vp "$PERSISTANT_DIR/$USER"
#    sudo chown $USER.$USER "$PERSISTANT_DIR/$USER"
#  fi
#  let USER_ID=$((++USER_INC + 327))
#done

  # Calculate to see if we are running in UPGRADE_MODE or not while checking
  # if we need to create persistant directories or not.
  # Basically assume we are because this is the safe route for production
  # systems.

  if [ "$2xx" = "xx" ] && [ -f "$SETUP_DIR/.env" ]; then
    . "$SETUP_DIR/.env"
  fi
  
  export ELASTIC_DAT_DIR=${ELASTIC_DAT_DIR:-"$PERSISTANT_DIR/elasticsearch"}
  export CLAMAV_DAT_DIR=${CLAMAV_DAT_DIR:-"$PERSISTANT_DIR/clamav"}
  export AMATICA_INC_DIR=${AMATICA_INC_DIR:-"$PERSISTANT_DIR/filesender"}
  export AMATICA_DAT_DIR=${AMATICA_DAT_DIR:-"$PERSISTANT_DIR/archivematica"}
  export MYSQL_DAT_DIR=${MYSQL_DAT_DIR:-"$PERSISTANT_DIR/mysql"}

# Ensure archivematica persistant dirs exist
AMATICA_LIST="\
$ELASTIC_DAT_DIR \
$CLAMAV_DAT_DIR \
$AMATICA_INC_DIR \
$AMATICA_DAT_DIR \
$MYSQL_DAT_DIR"

USER=archivematica

for AMATICA_DIR in $AMATICA_LIST; do
  if [ -e "$AMATICA_DIR" ] && [ ! -d "$AMATICA_DIR" ]; then
    echo "ERROR: persistant path $AMATICA_DIR exists and is not a directory."
    echo "ERROR: please correct this and re-run the script. Exiting"
    exit 1
  fi
  
  if [ ! -d "$AMATICA_DIR" ]; then
    sudo mkdir -vp "$AMATICA_DIR"
    #sudo chown $USER.$USER "$PERSISTANT_DIR/$AMATICA_DIR"
  else
    if [ "`ls -A $AMATICA_DIR`" ]; then
      UPGRADE_MODE="true"
    fi
  fi
done

  printenv | grep -e "AMATICA\|NGINX\|FILESENDER\|SMTP_\|MYSQL_\|DAT_DIR\|LOG_DIR\|ETC_DIR" | sort > "$SETUP_DIR/.env"
  
#}

function docker_compose_up {
  echo "CREATING docker containers in background with configuration saved in $SETUP_DIR/.env"
  echo
  
  # Taken from https://github.com/artefactual-labs/am/tree/master/compose
  cd ../artefactual-labs
  # Purposefully not doing un-necessary git submodule update --init --recursive
  git submodule update --init
  #git submodule update --init --recursive
  cd -
  
  cat ../artefactual-labs/compose/docker-compose.yml | \
    sed -e '/build:/d' \
        -e '/context:/d' \
        -e '/dockerfile:/d' \
        -e '/\.\.\/src\//d' \
        > docker-compose.yml

  #docker-compose config
  echo

  # Update the shibboleth attributes used:
  sed -i \
      -e 's/HTTP_EPPN/HTTP_SHIB_UID/g' \
      -e 's/HTTP_GIVENNAME/HTTP_SHIB_GIVENNAME/g' \
      -e 's/HTTP_SN/HTTP_SHIB_SN/g' \
      -e 's/HTTP_MAIL/HTTP_SHIB_MAIL/g' \
      -e 's/HTTP_ENTITLEMENT/HTTP_SHIB_ENTITLEMENT/g' \
      ../artefactual-labs/src/archivematica/src/dashboard/src/settings/components/shibboleth_auth.py
  
  # setup softlinks so commands below will work:
  test -L etc || ln -s ../artefactual-labs/compose/etc .
  test -L Makefile || ln -s ../artefactual-labs/compose/Makefile .
  test -L ../src || cd .. && ln -s artefactual-labs/src . && cd -
  #test -L src || ln -s ../artefactual-labs/src .
  
  # Integrate with amatica persistant storage mechanism for input and storage
  export AM_PIPELINE_DATA=${AMATICA_DAT_DIR}
  export SS_LOCATION_DATA=${AMATICA_INC_DIR}

  # Add our own persistant storage for mysql, elasticsearch, and clamav
  docker volume create --opt type=none --opt o=bind --opt device=${MYSQL_DAT_DIR} am-mysql-data
  docker volume create --opt type=none --opt o=bind --opt device=${ELASTIC_DAT_DIR} am-elasticsearch-data
  docker volume create --opt type=none --opt o=bind --opt device=${CLAMAV_DAT_DIR} am-clamav-data

  make create-volumes
  docker-compose build web
  docker-compose build shib
  docker-compose up -d mysql
  timeout 10 docker-compose logs --follow
  docker-compose up -d
  timeout 20 docker-compose logs --follow
  if [ "xx$UPGRADE_MODE" = "xx" ]; then
    echo "RUNNING a fresh install"
    make bootstrap
  else
    echo "RUNNING an upgrade"
    make manage-ss ARG="migrate --noinput"
    docker-compose restart archivematica-storage-service
    make manage-dashboard ARG="migrate --noinput"
    make bootstrap-dashboard-frontend
  fi
  
  make restart-am-services
}

METADATA_URL="https://$HOSTIP/Shibboleth.sso/Metadata"
METADATA_FILE="docker-filesender-phpfpm-shibboleth-$HOSTIP-metadata.xml"

if [ -f "$METADATA_FILE" ]; then
  if [ "`docker ps -a | grep archivematica`" = "" ]; then
    #create_persistant_dirs
    docker_compose_up
  fi
else
  
  if [ -f docker-compose.yml ]; then
    echo "STOPPING any docker-compose created images"
    docker-compose rm -fsv
    echo "y" | docker volume prune
  fi

DEVICE=$HOSTIP
SUBJECT="/C=FC/postalCode=FakeZip/ST=FakeState/L=FakeCity/streetAddress=FakeStreet/O=FakeOrganization/OU=FakeDepartment/CN=${DEVICE}"
DAYS=1095   # 3 * 365

function create_self_signed_cert {

  local DESTDIR=$1
  local CERT_KEY=$2
  local CERT_CSR=$3
  local CERT_SIGNED=$4

  echo "GENERATING ssl self-signed cert files"
  echo "   $DESTDIR/$CERT_SIGNED"
  echo "   $DESTDIR/$CERT_CSR"
  echo "   $DESTDIR/$CERT_KEY"
  
  # Create private key $CERT_KEY and csr $CERT_CSR:
  cd $DESTDIR
  openssl req -nodes -newkey rsa:2048 -keyout $CERT_KEY -subj "${SUBJECT}" -out $CERT_CSR
  
  # Create self-signed cert $CERT_SIGNED:
  local SIGNING_KEY="-signkey $CERT_KEY"
  
  openssl x509 -req -extfile <(printf "subjectAltName=DNS:$DEVICE") -in $CERT_CSR $SIGNING_KEY -out $CERT_SIGNED -days $DAYS -sha256

  chmod 644 $CERT_KEY
  cd -  
}

echo
# Create shibboleth self-signed certs
create_self_signed_cert shib/shibboleth sp-key.pem sp-csr.pem sp-cert.pem

# Create ngins self-signed certs ( browser will report "untrusted" error )
create_self_signed_cert web/nginx/conf.d host.key host.csr host.crt

function sed_file {
  local SRCFILE="$1"
  local DSTFILE="$2"

  cp -v "$SRCFILE" "$DSTFILE"
  sed -i \
      -e "s|{PUBLICIP}|$HOSTIP|g" \
      -e "s|{SHIB_UID}|$SHIB_UID|g" \
      -e "s|{SHIB_LNAME}|$SHIB_LNAME|g" \
      -e "s|{SHIB_FNAME}|$SHIB_FNAME|g" \
      -e "s|{SHIB_CNAME}|$SHIB_CNAME|g" \
      -e "s|{SHIB_MAIL}|$SHIB_MAIL|g" \
      "$DSTFILE"
}

echo
echo "CONFIGURING shibboleth"
sed_file template/shibboleth2.xml shib/shibboleth/shibboleth2.xml

echo "CONFIGURING nginx"
sed_file template/port443.conf web/nginx/conf.d/port443.conf
sed_file template/fastcgi_filesender web/nginx/conf.d/fastcgi_filesender
sed_file template/require_shib_session web/nginx/conf.d/require_shib_session

echo "CONFIGURING docker-compose"
sed_file template/docker-compose.override.yml docker-compose.override.yml

if [ "$RUN_MODE" != "config_only" ]; then
  #create_persistant_dirs
  docker_compose_up
  
  echo
  echo "WAITING for docker containers to be up"
  sleep 5
  
  RESULT=`nc -z -w1 ${HOSTIP} 443 && echo 1 || echo 0`
  
  while [ $RESULT -ne 1 ]; do
    echo " **** Nginx ${HOSTIP}:443 is not responding, waiting... **** "
    sleep 5
    RESULT=`nc -z -w1 ${HOSTIP} 443 && echo 1 || echo 0`
  done
  
  if [ ! -f "$METADATA_FILE" ]; then
    echo "RETRIEVING $METADATA_URL"
    sleep 2
    curl -k $METADATA_URL > $METADATA_FILE
  fi
else
  touch $METADATA_FILE
fi

fi

echo
echo "RERUN: to redo this setup, delete $METADATA_FILE and re-run ./setup-amatica-shib.sh $GIVENIP"
echo
echo "REGISTER this shibboleth instance by uploading file $SETUP_DIR/$METADATA_FILE to https://www.testshib.org/register.html#"
echo
echo "FINALLY browse to https://$HOSTIP:62080, user/pswd: test/test.You will need to accept any error indicating the https ssl cert is invalid or not private since a self-signed cert is being used instead of an ssl certificate registered with a certificate authority."
