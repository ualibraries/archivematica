#!/bin/sh
## Output from `debconf-get-selections | grep postfix`
## postfix  postfix/chattr boolean  false
## postfix  postfix/rfc1035_violation  boolean  false
## postfix  postfix/tlsmgr_upgrade_warning   boolean
## postfix  postfix/relay_restrictions_warning  boolean
## postfix  postfix/protocols select   all
## postfix  postfix/mailbox_limit   string   0
## postfix  postfix/sqlite_warning  boolean
# Install postfix despite an unsupported kernel?
## postfix  postfix/kernel_version_warning   boolean
## postfix  postfix/destinations string   smtpgate.mail.arizona.edu, glb-linux.library.arizona.edu, localhost.library.arizona.edu, localhost
## postfix  postfix/not_configured  error
## postfix  postfix/relayhost string   smtpgate.mail.arizona.edu
## postfix  postfix/procmail  boolean  false
## postfix  postfix/retry_upgrade_warning boolean
## postfix  postfix/root_address string
## postfix  postfix/recipient_delim string   +
## postfix  postfix/mailname  string   smtpgate.mail.arizona.edu
## postfix  postfix/bad_recipient_delimiter  error
## postfix  postfix/mydomain_warning   boolean
## postfix  postfix/mynetworks   string   127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128

## Values we want to set:
echo "postfix  postfix/main_mailer_type   select   Satellite system" | debconf-set-selections
echo "postfix  postfix/mailname  string   email.abcd.edu"          | debconf-set-selections
echo "postfix  postfix/relayhost string   smtp.abcd.edu" | debconf-set-selections
