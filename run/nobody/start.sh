#!/usr/bin/dumb-init /bin/bash

# use bash script to set incoming port and bind adapter and then start qBittorrent
/usr/local/bin/portget.sh /usr/bin/qbittorrent-nox --webui-port="${APPLICATION_PORT}" --profile=/config
