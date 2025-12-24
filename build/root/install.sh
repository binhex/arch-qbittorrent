#!/bin/bash

# exit script if return code != 0
set -e

# app name from buildx arg, used in healthcheck to identify app and monitor correct process
APPNAME="${1}"
shift

# release tag name from buildx arg, stripped of build ver using string manipulation
RELEASETAG="${1}"
shift

# target arch from buildx arg
TARGETARCH="${1}"
shift

if [[ -z "${APPNAME}" ]]; then
	echo "[warn] App name from build arg is empty, exiting script..."
	exit 1
fi

if [[ -z "${RELEASETAG}" ]]; then
	echo "[warn] Release tag name from build arg is empty, exiting script..."
	exit 1
fi

if [[ -z "${TARGETARCH}" ]]; then
	echo "[warn] Target architecture name from build arg is empty, exiting script..."
	exit 1
fi

# write APPNAME and RELEASETAG to file to record the app name and release tag used to build the image
echo -e "export APPNAME=${APPNAME}\nexport IMAGE_RELEASE_TAG=${RELEASETAG}\n" >> '/etc/image-build-info'

# ensure we have the latest builds scripts
refresh.sh

# compile qbittorrent-nox + libtorrentv1
####

# define path to store compiled packages
package_path="/tmp/package"

# build qbittorrent using makepkg and build and install libtorrent v1 using helper
# note we do not install qbittorrent as we need to ignore libtorrent-rasterbar before
# installing, also the qbittorrent package also includes qbittorrent and
# qbittorrent-nox, we only want to install qbittorrent-nox
aur.sh --aor-package 'qbittorrent' --aur-package 'libtorrent-rasterbar-1_2-git' --package-path "${package_path}"

# ignore aor package 'libtorrent-rasterbar' to prevent upgrade to libtorrent v2 as libtorrent
# v2 causes numerous issues, including crashing on unraid due to kernel bug
sed -i -e 's~IgnorePkg.*~IgnorePkg = filesystem libtorrent-rasterbar~g' '/etc/pacman.conf'

# define glob pattern for qbittorrent package(s)
glob_package='qbittorrent-nox*.tar.*'

# Find makepkg built package(s) recursively in package-path and install
packages=$(find "${package_path}" -name "${glob_package}" -type f 2>/dev/null)

if [[ -n "${packages}" ]]; then
    echo "[info] Found packages:"
    echo "${packages}"
    # Install each found package
    for package in ${packages}; do
        echo "[info] Installing package: ${package}"
        pacman -U "${package}" --noconfirm
    done
else
    echo "[warn] No packages found in ${package_path} directory tree"
    exit 1
fi

# pacman packages
####

# call pacman db and package updater script
source upd.sh

# define pacman packages
pacman_packages="python geoip"

# install compiled packages using pacman
if [[ -n "${pacman_packages}" ]]; then
	# arm64 currently targetting aor not archive, so we need to update the system first
	if [[ "${TARGETARCH}" == "arm64" ]]; then
		pacman -Syu --noconfirm
	fi
	pacman -S --needed $pacman_packages --noconfirm
fi

# container perms
####

# define comma separated list of paths
install_paths="/home/nobody"

# split comma separated string into list for install paths
IFS=',' read -ra install_paths_list <<< "${install_paths}"

# process install paths in the list
for i in "${install_paths_list[@]}"; do

	# confirm path(s) exist, if not then exit
	if [[ ! -d "${i}" ]]; then
		echo "[crit] Path '${i}' does not exist, exiting build process..." ; exit 1
	fi

done

# convert comma separated string of install paths to space separated, required for chmod/chown processing
install_paths=$(echo "${install_paths}" | tr ',' ' ')

# set permissions for container during build - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
chmod -R 775 ${install_paths}

# In install.sh heredoc, replace the chown section:
cat <<EOF > /tmp/permissions_heredoc
install_paths="${install_paths}"
EOF

# replace permissions placeholder string with contents of file (here doc)
sed -i '/# PERMISSIONS_PLACEHOLDER/{
    s/# PERMISSIONS_PLACEHOLDER//g
    r /tmp/permissions_heredoc
}' /usr/bin/init.sh
rm /tmp/permissions_heredoc

# env vars
####

cat <<'EOF' > /tmp/envvars_heredoc

# source in utility functions, need process_env_var
source utils.sh

# Define environment variables to process
# Format: "VAR_NAME:DEFAULT_VALUE:REQUIRED:MASK"
env_vars=(
	"GLUETUN_CONTROL_SERVER_PORT:8000:false:false"
	"GLUETUN_CONTROL_SERVER_USERNAME::false:false"
	"GLUETUN_CONTROL_SERVER_PASSWORD::false:true"
	"GLUETUN_INCOMING_PORT:no:false:false"
	"WEBUI_PORT:8080:false:false"
)

# Process each environment variable
for env_var in "${env_vars[@]}"; do
	IFS=':' read -r var_name default_value required mask_value <<< "${env_var}"
	process_env_var "${var_name}" "${default_value}" "${required}" "${mask_value}"
done

EOF

# replace env vars placeholder string with contents of file (here doc)
sed -i '/# ENVVARS_PLACEHOLDER/{
    s/# ENVVARS_PLACEHOLDER//g
    r /tmp/envvars_heredoc
}' /usr/bin/init.sh
rm /tmp/envvars_heredoc

# cleanup
cleanup.sh
