#!/bin/bash
set -x

DEFAULT_CONTAINER="amatica"

CONTAINER=${4:-$DEFAULT_CONTAINER}
REPOSITORY=${3:-archivematica}
TAG=${2:-1.7.1}
ACTION=${1:-BUILD}
DAEMONIZE=-d
DBUILD_SCRIPTS=`ls dbuild-*.sh`

git submodule update --init --recursive

for SCRIPT in $DBUILD_SCRIPTS; do
  echo "LAUNCHING $SCRIPT"
  ./$SCRIPT $ACTION
done
