#!/bin/sh

BASE_FILE="$(dirname $0)/base"
. "${BASE_FILE}"

umask ${UMASK_SET:-022}

if [ ! -f "${ARIA2_CONF}" ]; then
  INIT_FILE="$(dirname $0)/init.sh"
  . "${INIT_FILE}"
fi

for file in aria2.session dht.dat dht6.dat; do
  [ -f "${ARIA2_CONF_DIR}/${file}" ] || touch "${ARIA2_CONF_DIR}/${file}"
done

exec su-exec "${USER_NAME}:${USER_NAME}" aria2c \
  --conf-path=${ARIA2_CONF}

crond
