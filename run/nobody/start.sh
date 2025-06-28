#!/usr/bin/dumb-init /bin/bash

function start_qbittorrent() {

	echo "[INFO] Starting ${APPLICATION_NAME} Web UI..."

	# run process non daemonised (blocking)
	/usr/bin/qbittorrent-nox --webui-port="${APPLICATION_PORT}" --profile=/config

}

function common() {

  local session_lock_filepath="/config/qBittorrent/data/BT_backup/session.lock"

  echo "[info] Removing ${APPLICATION_NAME} session lock file (if it exists)..."
  rm -f "${session_lock_filepath}"

}

function main() {

	# running common setup tasks
	common

	if [[ "${CONFIGURE_INCOMING_PORT}" == "yes" ]]; then

		echo "[info] Starting ${APPLICATION_NAME} Web UI with port configuration..."
		/usr/local/bin/portget.sh --application-name "${APPLICATION_NAME}" --application-port "${APPLICATION_PORT}" /usr/bin/qbittorrent-nox --webui-port="${APPLICATION_PORT}" --profile=/config
	else
		echo "[info] Skipping port configuration as env var 'CONFIGURE_INCOMING_PORT' is not set to 'yes'"
		start_qbittorrent
	fi
}

main
