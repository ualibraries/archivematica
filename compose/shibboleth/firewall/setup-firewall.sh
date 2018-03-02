#!/bin/bash
#set -x

RUN_MODE="${1:-HOST|DOCKER}"
HOST_RULES=iptables.firewall.rules
DOCKER_RULES=iptables.docker-firewall.rules
SHOW_IPTABLES=
FIREWALL_DIR=.

function sed_file {
  local SRCFILE="$1"
  local DSTFILE="$2"

  cp -v "$SRCFILE" "$DSTFILE"

  if [ -z "$FIREWALL_SUBNET_1" ]; then
    sed -i -e "/192.168.118.0.23/d" "$DSTFILE"
  fi
  if [ -z "$FIREWALL_SUBNET_2" ]; then
    sed -i -e "/192.168.238.0.23/d" "$DSTFILE"
  fi
  if [ -z "$FIREWALL_SUBNET_3" ]; then
    sed -i -e "/192.168.113.192.255.255.255.240/d" "$DSTFILE"
  fi
  if [ -z "$FIREWALL_SUBNET_4" ]; then
    sed -i -e "/192.168.135.64.26/d" "$DSTFILE"
  fi
  if [ -z "$FIREWALL_SUBNET_5" ]; then
    sed -i -e "/192.168.155.0.24/d" "$DSTFILE"
  fi
  
  sed -i \
      -e "s|192.168.118.0/23|$FIREWALL_SUBNET_1|g" \
      -e "s|192.168.238.0/23|$FIREWALL_SUBNET_2|g" \
      -e "s|192.168.113.192/255.255.255.240|$FIREWALL_SUBNET_3|g" \
      -e "s|192.168.135.64/26|$FIREWALL_SUBNET_4|g" \
      -e "s|192.168.155.0/24|$FIREWALL_SUBNET_5|g" \
      -e "s|shibboleth.abcde.edu|$FIREWALL_SHIBBOLETH|g" \
      -e "s|smtp.abcde.edu|$FIREWALL_SMTP|g" \
      -e "s|ens160|$FIREWALL_DEVICE|g" \
      "$DSTFILE"
}

if [ "`echo $RUN_MODE | grep -i SED`" != "" ]; then
  echo "FIREWALL: creating iptable rule files"
  sed_file "$HOST_RULES-template" "$HOST_RULES"
  sed_file "$DOCKER_RULES-template" "$DOCKER_RULES"
fi

if [ "`echo $RUN_MODE | grep -i HOST`" != "" ]; then
  if [ -f "$FIREWALL_DIR/$HOST_RULES" ]; then
    echo "FIREWALL: protecting host system"
    cp -v "$FIREWALL_DIR/$HOST_RULES" /etc/
    cp -v "$FIREWALL_DIR/iptables.firewall.reset.open" /etc/
    cp -v "$FIREWALL_DIR/firewall" /etc/network/if-pre-up.d/firewall
    /etc/network/if-pre-up.d/firewall
  
    if [ -f "/etc/init.d/docker" ]; then
      /etc/init.d/docker restart
    fi
    SHOW_IPTABLES=true
  else
    echo "FIREWALL: missing $HOST_RULES file. Run ./setup-firewall.sh SED"
  fi
fi

if [ "`echo $RUN_MODE | grep -i DOCKER`" != "" ]; then
  if [ -f "$DOCKER_RULES" ]; then
    echo "FIREWALL: protecting docker"
    cp -v "$FIREWALL_DIR/docker-firewall.service" /lib/systemd/system
    cp -v "$FIREWALL_DIR/$DOCKER_RULES" /etc/
    systemctl enable docker-firewall
    systemctl daemon-reload
    systemctl start docker-firewall
    SHOW_IPTABLES=true
  else
    echo "FIREWALL: missing $DOCKER_RULES file. Run ./setup-firewall.sh SED"
  fi
fi

if [ "`echo $RUN_MODE | grep -i CLEAN`" != "" ]; then
  echo "FIREWALL: cleaning up files"
  systemctl disable docker-firewall
  rm -v /lib/systemd/system/docker-firewall.service
  systemctl daemon-reload
  iptables-restore /etc/iptables.firewall.reset.open
  if [ -f "/etc/init.d/docker" ]; then
    /etc/init.d/docker restart
  fi
  rm -v /etc/iptables.firewall.*
  rm -v /etc/network/if-pre-up.d/firewall
  rm -v /etc/iptables.docker-firewall.*
fi

if [ "$SHOW_IPTABLES" = "true" ]; then
  iptables -L
fi

# debug with setting logging to 'debug' in /etc/systemd/system.conf
#journalctl -xe
