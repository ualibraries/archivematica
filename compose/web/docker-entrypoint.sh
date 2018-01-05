#!/bin/sh

set +e

CONF_DIR="/opt/conf.d"
FILESENDER_DIR="/opt/filesender"
SIMPLESAML_DIR="/opt/simplesamlphp"
NGINX_SSL_DIR="/etc/ssl/nginx"
NGINX_CONF="${CONF_DIR}/nginx.conf"
NGINX_SSL_CONF="${CONF_DIR}/nginx-ssl.conf"
NGINX_CONF_DIR="/etc/nginx/conf.d"

DB_HOST=${DB_HOST:-localhost}
DB_NAME=${DB_NAME:-filesender}
DB_USER=${DB_USER:-filesender}
DB_PASSWORD=${DB_PASSWORD:-filesender}

if [ -d ${FILESENDER_DIR}-${FILESENDER_V} ]; then
    cp ${FILESENDER_DIR}-${FILESENDER_V}/* ${FILESENDER_DIR} -r
    rm -r ${FILESENDER_DIR}-${FILESENDER_V}
fi

if [ -d ${SIMPLESAML_DIR}-${SSP_V} ]; then
   cp ${SIMPLESAML_DIR}-${SSP_V}/* ${SIMPLESAML_DIR} -r
   rm -r ${SIMPLESAML_DIR}-${SSP_V}
fi

if [ -f ${CONF_DIR}/config.php ]; then
    cp ${CONF_DIR}/config.php ${FILESENDER_DIR}/config/config.php
else 
    cp ${CONF_DIR}/config-template.php ${FILESENDER_DIR}/config/config.php
    sed -i \
	-e "s/{DB_HOST}/${DB_HOST}/g" \
	-e "s/{DB_NAME}/${DB_NAME}/g" \
	-e "s/{DB_USER}/${DB_USER}/g" \
	-e "s/{DB_PASSWORD}/${DB_PASSWORD}/g" \
	-e "s/{ADMIN_USERS}/${ADMIN_USERS:-admin}/g" \
	-e "s/{SAML_MAIL_ATTR}/${SAML_MAIL_ATTR:-mail}/g" \
	-e "s/{SAML_NAME_ATTR}/${SAML_NAME_ATTR:-displayName}/g" \
	-e "s/{SAML_UID_ATTR}/${SAML_UID_ATTR:-uid}/g" \
    "${FILESENDER_DIR}/config/config.php"
fi


if [ -f ${CONF_DIR}/saml20-idp-remote.php ]; then
   echo "Copying SAML2 remote IdP metadata file..."
   cp ${CONF_DIR}/saml20-idp-remote.php ${SIMPLESAML_DIR}/metadata/saml20-idp-remote.php
fi

if [ -f ${CONF_DIR}/simplesamlphp_config.php ]; then
   echo "Copying SAML2 config file..."
   cp ${CONF_DIR}/simplesamlphp_config.php ${SIMPLESAML_DIR}/config/config.php
fi

if [ -f ${CONF_DIR}/simplesamlphp_authsources.php ]; then
   echo "Copying SAML2 authsources file..."
   cp ${CONF_DIR}/simplesamlphp_authsources.php ${SIMPLESAML_DIR}/config/authsources.php
fi

if [ -d ${CONF_DIR}/metadata-import ]; then
   echo "Copying SAML2 metadata import directory..."
   cp -r ${CONF_DIR}/metadata-import ${SIMPLESAML_DIR}/metadata
fi


if [ -d ${CONF_DIR}/cert ]; then
   echo "Copying certificates to SimpleSAMLphp cert dir..."
   cp ${CONF_DIR}/cert ${SIMPLESAML_DIR} -r
fi


if [ -e /usr/bin/mysql ]; then
    RESULT=`nc -z -w1 ${DB_HOST} 3306 && echo 1 || echo 0`

    while [ $RESULT -ne 1 ]; do
	  echo " **** Database is not responding, waiting... **** "
	  sleep 5
	  RESULT=`nc -z -w1 ${DB_HOST} 3306 && echo 1 || echo 0`
    done

    SQL_FILE=${FILESENDER_DIR}/scripts/mysql_filesender_db.sql

    cp ${CONF_DIR}/mysql_filesender_db.sql ${SQL_FILE}
    sed -i \
	-e "s/{DB_NAME}/${DB_NAME}/g" \
    "${SQL_FILE}"

    mysql -h ${DB_HOST} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < ${SQL_FILE}
fi

if [ -d $NGINX_SSL_DIR ]; then
   if [ ! -f "$NGINX_CONF_DIR/nginx-ssl.conf" ]; then
       echo " **** Configuring Nginx to use HTTPS **** "

       cp $NGINX_SSL_CONF "$NGINX_CONF_DIR/nginx-ssl.conf"

       sed -i \
           -e "s/{FILESENDER_DOMAIN}/${FILESENDER_DOMAIN:-localhost}/g" \
       "$NGINX_CONF_DIR/nginx-ssl.conf"
 
   fi
else
    if [ ! -f "$NGINX_CONF_DIR/nginx.conf" ]; then
        echo " **** Cert dir '$NGINX_SSL_DIR' does not exist **** "
        echo " **** Configuring Nginx for HTTP only **** "

        cp $NGINX_CONF "$NGINX_CONF_DIR/nginx.conf"

	sed -i \
            -e "s/{FILESENDER_DOMAIN}/${FILESENDER_DOMAIN:-localhost}/g" \
	"$NGINX_CONF_DIR/nginx.conf"
    fi
fi

chown -R nginx:nginx ${FILESENDER_DIR} ${SIMPLESAML_DIR}
chmod -R g+w ${FILESENDER_DIR} ${SIMPLESAML_DIR}

exec nginx -g "daemon off;"
