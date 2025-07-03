#!/usr/bin/dumb-init /bin/bash

function start_qbittorrent() {

	echo "[INFO] Starting qbittorrent Web UI..."

	# run process non daemonised (blocking)
	/usr/bin/qbittorrent-nox --webui-port="${WEBUI_PORT}" --profile=/config

}

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

	if [[ "${GLUETUN_INCOMING_PORT}" == "yes" ]]; then

		echo "[info] Starting qbittorrent Web UI with port configuration..."
		/usr/local/bin/portget.sh --application-name 'qbittorrent' --webui-port "${WEBUI_PORT}" /usr/bin/qbittorrent-nox --webui-port="${WEBUI_PORT}" --profile=/config
	else
		echo "[info] Skipping VPN incoming port configuration as env var 'GLUETUN_INCOMING_PORT' is not set to 'yes'"
		start_qbittorrent
	fi
}

main
