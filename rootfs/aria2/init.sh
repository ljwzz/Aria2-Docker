#!/bin/sh

BASE_FILE="$(dirname $0)/base"
. "${BASE_FILE}"

mkdir -p "${SCRIPT_DIR}"

cp -r /aria2/default-config/* "${ARIA2_CONF_DIR}"

[[ ${RPC_SECRET} ]] &&
  sed -i "s@^\(rpc-secret=\).*@\1${RPC_SECRET}@" ${ARIA2_CONF}

# set id
PUID=${PUID:-65534}
PGID=${PGID:-65534}

groupmod -og $PGID ${USER_NAME}
usermod -ou $PUID ${USER_NAME}

cat <<-EOM
-------------------------------------
User UID: $(id -u ${USER_NAME})
User GID: $(id -g ${USER_NAME})
-------------------------------------
EOM

# set timezone
if [[ -n "${TZ}" && -f "/usr/share/zoneinfo/${TZ}" ]]; then
  ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
  echo "${TZ}" >/etc/timezone
else
  echo "WARNING: ${TZ} is not a valid time zone."
  ln -sf /usr/share/zoneinfo/UTC /etc/localtime
  echo UTC >/etc/timezone
fi

# set permissions
if [ -w ${DOWNLOAD_DIR} ]; then
  echo "Download DIR writeable, not changing owner."
else
  chown -R ${USER_NAME}:${USER_NAME} ${DOWNLOAD_DIR}
fi

chown -R ${USER_NAME}:${USER_NAME} ${ARIA2_CONF_DIR}
if [[ -z ${PUID} && -z ${PGID} ]] || [[ ${PUID} = 65534 && ${PGID} = 65534 ]]; then
  echo -e "${WARN} Ignore permission settings."
  chmod -v 777 ${DOWNLOAD_DIR}
  chmod -vR 777 ${ARIA2_CONF_DIR}
else
  if [ -w ${DOWNLOAD_DIR} ]; then
    echo "Download DIR writeable, not modifying permission."
  else
    chmod -v u=rwx ${DOWNLOAD_DIR}
  fi
  chmod -v 600 ${ARIA2_CONF_DIR}/*
  chmod -v 755 ${SCRIPT_DIR}
  chmod -v 700 ${SCRIPT_DIR}/*
fi
