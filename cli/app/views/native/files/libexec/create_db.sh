#!/usr/bin/env bash

set -eEuo pipefail

. ${BASE_DIR}/libexec/lib.sh

if [ ! -d $DB_DIR ]; then
  initdb $DB_DIR

  _sed -i $DB_DIR/postgresql.conf \
    -e "s@^#*unix_socket_directories .*@unix_socket_directories = '.'@" \
    -e "s@^#*port .*@port = ${DB_PORT}@"

  postgres -D $DB_DIR &

  wait_db_socket

  createuser \
    --host $DB_DIR \
    --createdb \
    --login \
    --superuser \
    $RAILS_DATABASE_USER

  killall postgres

  # wait for postgres to exit
  sleep 5
fi
