#!/bin/sh
## Values from `debconf-get-selections | grep archivematica-mcp-server`
## archivematica-mcp-server   archivematica-mcp-server/mysql/admin-pass password
## archivematica-mcp-server   archivematica-mcp-server/app-password-confirm   password
## archivematica-mcp-server   archivematica-mcp-server/password-confirm password
## # MySQL application password for archivematica-mcp-server:
## archivematica-mcp-server   archivematica-mcp-server/mysql/app-pass   password
## archivematica-mcp-server   archivematica-mcp-server/internal/skip-preseed  boolean  false
## archivematica-mcp-server   archivematica-mcp-server/internal/reconfiguring boolean  false
## archivematica-mcp-server   archivematica-mcp-server/remove-error  select   abort
## # MySQL username for archivematica-mcp-server:
## archivematica-mcp-server   archivematica-mcp-server/db/app-user   string   archivematica
## # MySQL database name for archivematica-mcp-server:
## archivematica-mcp-server   archivematica-mcp-server/db/dbname  string   MCP
## # Reinstall database for archivematica-mcp-server?
## archivematica-mcp-server   archivematica-mcp-server/dbconfig-reinstall  boolean  false
## # Database type to be used by archivematica-mcp-server:
## archivematica-mcp-server   archivematica-mcp-server/database-type select   mysql
## archivematica-mcp-server   archivematica-mcp-server/passwords-do-not-match error
## archivematica-mcp-server   archivematica-mcp-server/mysql/admin-user string   root
## # Deconfigure database for archivematica-mcp-server with dbconfig-common?
## archivematica-mcp-server   archivematica-mcp-server/dbconfig-remove  boolean
## archivematica-mcp-server   archivematica-mcp-server/remote/port   string
## # Do you want to back up the database for archivematica-mcp-server before upgrading?
## archivematica-mcp-server   archivematica-mcp-server/upgrade-backup   boolean  true
## # Host running the MySQL server for archivematica-mcp-server:
## archivematica-mcp-server   archivematica-mcp-server/remote/newhost   string
## # Perform upgrade on database for archivematica-mcp-server with dbconfig-common?
## archivematica-mcp-server   archivematica-mcp-server/dbconfig-upgrade boolean  true
## # Configure database for archivematica-mcp-server with dbconfig-common?
## archivematica-mcp-server   archivematica-mcp-server/dbconfig-install boolean  true
## archivematica-mcp-server   archivematica-mcp-server/missing-db-package-error  select   abort
## # Connection method for MySQL database of archivematica-mcp-server:
## archivematica-mcp-server   archivematica-mcp-server/mysql/method  select   unix socket
## # Host name of the MySQL database server for archivematica-mcp-server:
## archivematica-mcp-server   archivematica-mcp-server/remote/host   select
## # Do you want to purge the database for archivematica-mcp-server?
## archivematica-mcp-server   archivematica-mcp-server/purge   boolean  false
## archivematica-mcp-server   archivematica-mcp-server/upgrade-error select   abort
## archivematica-mcp-server   archivematica-mcp-server/install-error select   abort

echo "archivematica-mcp-server   archivematica-mcp-server/mysql/admin-pass password"      | debconf-set-selections
echo "archivematica-mcp-server   archivematica-mcp-server/dbconfig-install boolean  true" | debconf-set-selections
