#!/usr/bin/dumb-init /bin/bash

function common() {

  local session_lock_filepath="/config/qBittorrent/data/BT_backup/session.lock"

  echo "[info] Removing qbittorrent session lock file (if it exists)..."
  rm -f "${session_lock_filepath}"

}

function get_arch() {

	local arch
	arch=$(uname -m)

	case "$arch" in
		x86_64|amd64)
			echo "amd64"
			;;
		aarch64|arm64)
			echo "arm64"
			;;
		armv7l|armhf)
			echo "armv7"
			;;
		armv6l)
			echo "armv6"
			;;
		i386|i686)
			echo "386"
			;;
		*)
			echo "$arch"
			;;
	esac

}

function wait_pacman() {

	while [[ -f '/var/lib/pacman/db.lck' ]]; do
		sleep 1s
	done

}

function libtorrent() {

	# get arch from helper
	local target_arch
	target_arch="$(get_arch)"

	# ensure we delete any previous pacman lock files
	rm -f '/var/lib/pacman/db.lck'

	if [[ "${LIBTORRENT_VERSION}" == '1' ]]; then

		# uninstall libtorrent v2
		pacman -Rdd libtorrent-rasterbar --noconfirm 2>/dev/null
		wait_pacman

		# set package type extension depending on arch
		if [[ "${target_arch}" == 'amd64' ]]; then
			extension='x86_64.pkg.tar.zst'
		else
			extension='aarch64.pkg.tar.xz'
		fi

		# install libtorrent v1 and dependencies
		package_name="boost1.86-libs-${extension}"
		rcurl.sh -o "/tmp/${package_name}" "https://github.com/binhex/packages/raw/refs/heads/master/compiled/${target_arch}/${package_name}"
		pacman -U "/tmp/${package_name}" --noconfirm
		wait_pacman

		package_name="boost1.86-${extension}"
		rcurl.sh -o "/tmp/${package_name}" "https://github.com/binhex/packages/raw/refs/heads/master/compiled/${target_arch}/${package_name}"
		pacman -U "/tmp/${package_name}" --noconfirm
		wait_pacman

		package_name="libtorrent-rasterbar-1_2-git-${extension}"
		rcurl.sh -o "/tmp/${package_name}" "https://github.com/binhex/packages/raw/refs/heads/master/compiled/${target_arch}/${package_name}"
		pacman -U "/tmp/${package_name}" --noconfirm
		wait_pacman

	elif [[ "${LIBTORRENT_VERSION}" == '2' ]]; then

		# uninstall libtorrent v1 and dependencies
		package_name="libtorrent-rasterbar-1_2-git-${extension}"
		pacman -Rdd "${package_name}" --noconfirm 2>/dev/null
		wait_pacman

		package_name="boost1.86-${extension}"
		pacman -Rdd "${package_name}" --noconfirm 2>/dev/null
		wait_pacman

		package_name="boost1.86-libs-${extension}"
		pacman -Rdd "${package_name}" --noconfirm 2>/dev/null
		wait_pacman

		# install libtorrent v2
		pacman -S libtorrent-rasterbar --noconfirm
		wait_pacman

	fi

}

function main() {

	# running common setup tasks
	common

	# set libtorrent version (as root)
	libtorrent

	if [[ -z "${WEBUI_PORT}" ]]; then
		echo "[info] Environment variable 'WEBUI_PORT' is not set, defaulting to 8080..."
		WEBUI_PORT=8080
	else
		echo "[info] Using WEBUI_PORT=${WEBUI_PORT}"
	fi

	echo "[info] Starting ${APPNAME} Web UI..."
	su nobody -c "bash -c 'portset.sh --webui-port ${WEBUI_PORT} --app-parameters /usr/bin/qbittorrent-nox --webui-port=${WEBUI_PORT} --profile=/config'"
}

main
