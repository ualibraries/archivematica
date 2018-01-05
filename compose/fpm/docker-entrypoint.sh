#!/bin/sh

set -e

USER='nginx'
USER_ID='101'
GROUP_ID='101'

FILESENDER_DOMAIN=${FILESENDER_DOMAIN:-localhost}
SMTP_SERVER=${SMTP_SERVER:-localhost}

if [ `id -u ${USER} 2>/dev/null || echo -1` -lt 0 ]; then
    addgroup -S -g ${GROUP_ID} ${USER}
    adduser -S -D -H -G ${USER} -u ${USER_ID} ${USER}
fi

printf "root=postmaster\nmailhub=${SMTP_SERVER}\nhostname=\"${FILESENDER_DOMAIN}\"\n" > /etc/ssmtp/ssmtp.conf

if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"
