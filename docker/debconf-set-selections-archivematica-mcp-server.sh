#!/bin/sh

if [ "$DB_TYPE" != "" ]; then
  # Database type to be used by archivematica-mcp-server:" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/database-type	select	$DB_TYPE" | debconf-set-selections
else
  echo "archivematica-mcp-server	archivematica-mcp-server/database-type	select	mysql" | debconf-set-selections
fi

echo "archivematica-mcp-server	archivematica-mcp-server/dbconfig-install	boolean	true" | debconf-set-selections

if [ "$MYSQL_UPGRADEDB" != "" ]; then
# Perform upgrade on database for archivematica-mcp-server with dbconfig-common?
  echo "archivematica-mcp-server	archivematica-mcp-server/dbconfig-reinstall	boolean	true" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/dbconfig-upgrade	boolean	true" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/missing-db-package-error	select	abort" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/upgrade-error	select	abort" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/remove-error	select	abort" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/internal/skip-preseed	boolean	false" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/dbconfig-remove	boolean	true" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/passwords-do-not-match	error	" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/install-error	select	abort" | debconf-set-selections
# Do you want to back up the database for archivematica-mcp-server before upgrading?
  echo "archivematica-mcp-server	archivematica-mcp-server/upgrade-backup	boolean	true" | debconf-set-selections
fi

if [ "$DB_ADMIN" != "" ]; then
  echo "archivematica-mcp-server	archivematica-mcp-server/mysql/admin-user	string	$DB_ADMIN" | debconf-set-selections
fi

if [ "$DB_ADMIN_PASSWORD" != "" ]; then
  echo "archivematica-mcp-server	archivematica-mcp-server/mysql/admin-pass	password	$DB_ADMIN_PASSWORD" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/password-confirm	password	$DB_ADMIN_PASSWORD" | debconf-set-selections
else
  echo "archivematica-mcp-server   archivematica-mcp-server/mysql/admin-pass password"      | debconf-set-selections
fi

if [ "$DB_PASSWORD" != "" ]; then
  echo "archivematica-mcp-server	archivematica-mcp-server/mysql/app-pass	password	$DB_PASSWORD" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/app-password-confirm	password	$DB_PASSWORD" | debconf-set-selections
fi

if [ "$DB_USER" != "" ]; then
  echo "archivematica-mcp-server	archivematica-mcp-server/db/app-user	string	$DB_USER" | debconf-set-selections
fi

if [ "$DB_DATABASE" != "" ]; then
# MySQL database name for archivematica-mcp-server:" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/db/dbname	string	$DB_DATABASE" | debconf-set-selections
fi

if [ "$DB_HOST" != "" ] && [ "$DB_HOST" != "localhost" ]; then
# Connection method for MySQL database of archivematica-mcp-server:" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/mysql/method	select	tcp/ip" | debconf-set-selections

# Host name of the MySQL database server for archivematica-mcp-server:
  echo "archivematica-mcp-server	archivematica-mcp-server/remote/host	select	$DB_HOST" | debconf-set-selections
  echo "archivematica-mcp-server	archivematica-mcp-server/remote/newhost	string	$DB_HOST" | debconf-set-selections
fi

if [ "$DB_PORT" != "" ]; then
  echo "archivematica-mcp-server	archivematica-mcp-server/remote/port	string	$DB_PORT" | debconf-set-selections
fi

# Do you want to purge the database for archivematica-mcp-server?
#echo "archivematica-mcp-server	archivematica-mcp-server/purge	boolean	false" | debconf-set-selections
#echo "archivematica-mcp-server	archivematica-mcp-server/internal/reconfiguring	boolean	false" | debconf-set-selections

