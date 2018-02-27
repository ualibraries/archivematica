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

echo "WORKINGDIR: $SETUP_DIR"
cd $SETUP_DIR

GIVENIP=$1
HOSTIP=$1
PERSISTANT_DIR=${2:-./persistant}
LOGGING_DIR=${3:-./log}

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

# Ensure archivematica users exist
USER_LIST="_shibd elasticsearch gearman nginx clamav mysql archivematica"
USER_ID=799
USER_INC=0

for USER in $USER_LIST; do
  #sudo deluser --remove-home $USER
  if [ "`id $USER 2>/dev/null`" = "" ]; then
    echo "CREATEUSER: $USER with uid:gid $USER_ID:$USER_ID"
    sudo addgroup $USER --force-badname --gid $USER_ID
    sudo adduser --system $USER --force-badname --uid $USER_ID --gid $USER_ID --home /var/lib/$USER --shell /bin/false
  fi
  if [ ! -d "$PERSISTANT_DIR/$USER" ]; then
    mkdir -vp "$PERSISTANT_DIR/$USER"
    sudo chown $USER.$USER "$PERSISTANT_DIR/$USER"
  fi
  let USER_ID=$((++USER_INC + 327))
done

# Shibboleth does not have a persistance dir
rmdir "$PERSISTANT_DIR/_shibd"

# Ensure archivematica persistant dir exist
AMATICA_LIST="filesender AIPstore"
USER=archivematica

for AMATICA_DIR in $AMATICA_LIST; do
  if [ ! -d "$PERSISTANT_DIR/$AMATICA_DIR" ]; then
    sudo mkdir -vp "$PERSISTANT_DIR/$AMATICA_DIR"
    sudo chown $USER.$USER "$PERSISTANT_DIR/$AMATICA_DIR"
  fi
done

LOGDIR_LIST="shibboleth amatica nginx filesender mysql supervisor"

if [ ! -d "$LOGGING_DIR/amatica/archivematica" ]; then
for LOGDIR in $LOGDIR_LIST; do
  echo "CREATELOGDIR: $LOGGING_DIR/$LOGDIR"
  sudo mkdir -vp "$LOGGING_DIR/$LOGDIR"
  sudo chmod 777 "$LOGGING_DIR/$LOGDIR"
done

  cd "$LOGGING_DIR"
  sudo tar -xzvf $SETUP_DIR/template/var.log.archivematica.tar.gz
  sudo mv var.log.archivematica/* amatica
  sudo rmdir var.log.archivematica
  cd ..
fi

function docker_compose_up {
  echo "CREATING docker containers in background"
  
  export NGINX_LOG_DIR=${NGINX_LOG_DIR:-"$LOGGING_DIR/nginx"}
  export SHIBBOLETH_LOG_DIR=${SHIBBOLETH_LOG_DIR:-"$LOGGING_DIR/shibboleth"}
  export SUPERVISOR_LOG_DIR=${SUPERVISOR_LOG_DIR:-"$LOGGING_DIR/supervisor"}
  export AMATICA_LOG_DIR=${AMATICA_LOG_DIR:-"$LOGGING_DIR/amatica"}
  export FILESENDER_LOG_DIR=${FILESENDER_LOG_DIR:-"$LOGGING_DIR/filesender"}
  export FILESENDER_DAT_DIR=${FILESENDER_DAT_DIR:-"$PERSISTANT_DIR/filesender"}
  export ELASTIC_DAT_DIR=${ELASTIC_DAT_DIR:-"$PERSISTANT_DIR/elasticsearch"}
  export GEARMAN_DAT_DIR=${GEARMAN_DAT_DIR:-"$PERSISTANT_DIR/gearman"}
  export CLAMAV_DAT_DIR=${CLAMAV_DAT_DIR:-"$PERSISTANT_DIR/clamav"}
  export AMATICA_INC_DIR=${AMATICA_INC_DIR:-"$PERSISTANT_DIR/filesender"}
  export AMATICA_DAT_DIR=${AMATICA_DAT_DIR:-"$PERSISTANT_DIR/archivematica"}
  export MYSQL_DAT_DIR=${MYSQL_DAT_DIR:-"$PERSISTANT_DIR/mysql"}
  
  docker-compose up -d
}

METADATA_URL="https://$HOSTIP/Shibboleth.sso/Metadata"
METADATA_FILE="docker-filesender-phpfpm-shibboleth-$HOSTIP-metadata.xml"

if [ -f "$METADATA_FILE" ]; then
  if [ "`docker ps -a | grep archivematica`" = "" ]; then
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
      "$DSTFILE"
}

echo
echo "CONFIGURING shibboleth"
sed_file template/shibboleth2.xml shib/shibboleth/shibboleth2.xml

echo "CONFIGURING nginx"
sed_file template/port443.conf web/nginx/conf.d/port443.conf
sed_file template/port8089.conf web/nginx/conf.d/port8089.conf
sed_file template/fastcgi_filesender web/nginx/conf.d/fastcgi_filesender
sed_file template/require_shib_session web/nginx/conf.d/require_shib_session

echo "CONFIGURING docker-compose"
sed_file template/docker-compose.yml docker-compose.yml

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

fi

echo
echo "RERUN: to redo this setup, delete $METADATA_FILE and re-run ./setup-amatica-shib.sh $GIVENIP"
echo
echo "REGISTER this shibboleth instance by uploading file $SETUP_DIR/$METADATA_FILE to https://www.testshib.org/register.html#"
echo
echo "FINALLY browse to https://$HOSTIP .You will need to accept any error indicating the https ssl cert is invalid or not private since a self-signed cert is being used instead of an ssl certificate registered with a certificate authority."
