#!/bin/sh

echo " * Archivematica Setup Beginning..."

# Create setup log header that will get mailed
cat <<EOF  > "$SETUP_LOG"
Subject: Archivematica setup is finished.

EOF

# Run and time the main setup script
time -o "$SETUP_LOG" -a ./setup-archivematica.sh >> "$SETUP_LOG" 2>&1

# Email the setup log
cat "$SETUP_LOG" | sendmail $SENDMAIL_ENDPOINTS

echo " * Archivematica Setup Finished."
