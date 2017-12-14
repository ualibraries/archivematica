echo foo-owner-package-name foo-template-name value-type value | debconf-set-selections

root@4d28ce831a8d:~# debconf-get-selections | grep archivematica.mcp.server
archivematica-mcp-server   archivematica-mcp-server/mysql/admin-pass password
archivematica-mcp-server   archivematica-mcp-server/password-confirm password
archivematica-mcp-server   archivematica-mcp-server/app-password-confirm   password
# MySQL application password for archivematica-mcp-server:
archivematica-mcp-server   archivematica-mcp-server/mysql/app-pass   password
# Host running the MySQL server for archivematica-mcp-server:
archivematica-mcp-server   archivematica-mcp-server/remote/newhost   string   db-host
archivematica-mcp-server   archivematica-mcp-server/remote/port   string
# Delete the database for archivematica-mcp-server?
archivematica-mcp-server   archivematica-mcp-server/purge   boolean  false
# Reinstall database for archivematica-mcp-server?
archivematica-mcp-server   archivematica-mcp-server/dbconfig-reinstall  boolean  true
# Host name of the MySQL database server for archivematica-mcp-server:
archivematica-mcp-server   archivematica-mcp-server/remote/host   select   db-host
# Back up the database for archivematica-mcp-server before upgrading?
archivematica-mcp-server   archivematica-mcp-server/upgrade-backup   boolean  true
# Database type to be used by archivematica-mcp-server:
archivematica-mcp-server   archivematica-mcp-server/database-type select   mysql
# Perform upgrade on database for archivematica-mcp-server with dbconfig-common?
archivematica-mcp-server   archivematica-mcp-server/dbconfig-upgrade boolean  true
# MySQL username for archivematica-mcp-server:
archivematica-mcp-server   archivematica-mcp-server/db/app-user   string   archivematicaDBA
archivematica-mcp-server   archivematica-mcp-server/upgrade-error select   abort
archivematica-mcp-server   archivematica-mcp-server/mysql/admin-user string   root
archivematica-mcp-server   archivematica-mcp-server/remove-error  select   abort
archivematica-mcp-server   archivematica-mcp-server/internal/reconfiguring boolean  false
# Connection method for MySQL database of archivematica-mcp-server:
archivematica-mcp-server   archivematica-mcp-server/mysql/method  select   TCP/IP
# MySQL database name for archivematica-mcp-server:
archivematica-mcp-server   archivematica-mcp-server/db/dbname  string   archivematica
archivematica-mcp-server   archivematica-mcp-server/internal/skip-preseed  boolean  false
archivematica-mcp-server   archivematica-mcp-server/passwords-do-not-match error
# Configure database for archivematica-mcp-server with dbconfig-common?
archivematica-mcp-server   archivematica-mcp-server/dbconfig-install boolean  true
archivematica-mcp-server   archivematica-mcp-server/missing-db-package-error  select   abort
# Deconfigure database for archivematica-mcp-server with dbconfig-common?
archivematica-mcp-server   archivematica-mcp-server/dbconfig-remove  boolean  true
archivematica-mcp-server   archivematica-mcp-server/install-error select   abort

