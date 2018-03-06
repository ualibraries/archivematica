#!/bin/sh

# Check environment for uid:gid changes
for USER in elasticsearch gearman nginx clamav mysql archivematica; do
  UCUSER=`echo $USER | awk '{print toupper ($0)}'`
  eval "USERVAL=\$CHOWN_$UCUSER"
  if [ "$USERVAL" != "" ]; then
      UID=${USERVAL%%:*}
      GID=${USERVAL##*:}
      if [ "$GID" = "" ]; then
        GID=$UID
      fi
      case $USER in
          elasticsearch) OLD_ID=328 ;;
          gearman)       OLD_ID=329 ;;
          nginx)         OLD_ID=330 ;;
          clamav)        OLD_ID=331 ;;
          mysql)         OLD_ID=332 ;;
          archivematica) OLD_ID=333 ;;
      esac
      echo "CHOWN: $USER $OLD_ID:$OLD_ID to $UID:$GID"
      groupmod -g $GID $USER
      usermod -u $UID $USER
      find / -path /proc -prune -group $OLD_ID -exec chgrp -h $USER {} \;
      find / -path /proc -prune -user $OLD_ID -exec chown -h $USER {} \;
  fi
done
