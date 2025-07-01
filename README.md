# Application

<!-- markdownlint-disable MD033 -->
[qBittorrent](https://www.qbittorrent.org/)

## Description

qBittorrent is a bittorrent client programmed in C++ / Qt that uses libtorrent
(sometimes called libtorrent-rasterbar) by Arvid Norberg. It aims to be a good
alternative to all other bittorrent clients out there. qBittorrent is fast,
stable and provides unicode support as well as many features.

## Build notes

Latest stable qBittorrent release from Arch Linux repo.

## Usage

```text
docker run -d \

    -p 8080:8080 \
    -p 58946:58946 \
    -p 58946:58946/udp \
    --name=<container name> \
    -v <path for data files>:/data \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e GLUETUN_INCOMING_PORT=<yes|no> \
    -e APPLICATION_PORT=<port> \
    -e ENABLE_STARTUP_SCRIPTS=<yes|no> \
    -e DEBUG=<true|false> \
    -e UMASK=<umask for created files> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \

    binhex/arch-qbittorrent

```

Please replace all user variables in the above command defined by <> with the
correct values.

## Access qBittorrent (web ui)

`http://<host ip>:8080/`

Username:- `admin`

Password:- randomly generated, password shown in `/config/supervisord.log`

## PIA example

```bash
docker run -d \

    -p 8080:8080 \
    -p 58946:58946 \
    -p 58946:58946/udp \
    --name=qbittorrent \
    -v /root/docker/data:/data \
    -v /root/docker/config:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e GLUETUN_INCOMING_PORT=no \
    -e APPLICATION_PORT=8080 \
    -e ENABLE_STARTUP_SCRIPTS=no \
    -e DEBUG=false \
    -e WEBUI_PORT=8080 \
    -e UMASK=000 \
    -e PUID=0 \
    -e PGID=0 \

    binhex/arch-qbittorrent

```

Due to issues with CSRF and port mapping, should you require to alter the port
for the webui you need to change both sides of the -p 8080 switch AND set the
WEBUI_PORT variable to the new port.

For example, to set the port to 8090 you need to set:-

```bash

    -p 8090:8090 \

```

and

```bash

    -e WEBUI_PORT=8090 \

```

---

If you appreciate my work, then please consider buying me a beer  :D

[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MM5E27UX6AUU4)

[Documentation](https://github.com/binhex/documentation) | [Support forum](https://forums.unraid.net/topic/75539-support-binhex-qbittorrentvpn/)
