#!/usr/bin/dumb-init /bin/bash

function common() {

  local session_lock_filepath="/config/qBittorrent/data/BT_backup/session.lock"

  echo "[info] Removing qbittorrent session lock file (if it exists)..."
  rm -f "${session_lock_filepath}"

}

function main() {

	# running common setup tasks
	common

	if [[ -z "${WEBUI_PORT}" ]]; then
		echo "[info] Environment variable 'WEBUI_PORT' is not set, defaulting to 8080..."
		WEBUI_PORT=8080
	else
		echo "[info] Using WEBUI_PORT=${WEBUI_PORT}"
	fi

	echo "[info] Starting ${APPNAME} Web UI..."
	portset.sh \
		--webui-port "${WEBUI_PORT}" \
		--gluetun-incoming-port "${GLUETUN_INCOMING_PORT}" \
		--gluetun-control-server-port "${GLUETUN_CONTROL_SERVER_PORT}" \
		--gluetun-control-server-username "${GLUETUN_CONTROL_SERVER_USERNAME}" \
		--gluetun-control-server-password "${GLUETUN_CONTROL_SERVER_PASSWORD}" \
		--app-parameters /usr/bin/qbittorrent-nox \
		--webui-port="${WEBUI_PORT}" \
		--profile=/config

}

main
