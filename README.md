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

```bash
docker run -d \
    -p 8080:8080 \
    -p 58946:58946 \
    -p 58946:58946/udp \
    --name=<container name> \
    -v <path for data files>:/data \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e GLUETUN_INCOMING_PORT=<yes|no> \
    -e ENABLE_STARTUP_SCRIPTS=<yes|no> \
    -e DEBUG=<true|false> \
    -e HEALTHCHECK_COMMAND=<command> \
    -e HEALTHCHECK_ACTION=<action> \
    -e HEALTHCHECK_HOSTNAME=<hostname> \
    -e UMASK=<umask for created files> \
    -e WEBUI_PORT=<port> \
    -e QBITTORRENT_WEBUI_USER=<username> \
    -e QBITTORRENT_WEBUI_PASSWORD=<password> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    binhex/arch-qbittorrent
```

Please replace all user variables in the above command defined by <> with the
correct values.

## Access qBittorrent (web ui)

`http://<host ip>:8080/`

### Credentials

| Variable | Default | Description |
| --- | --- | --- |
| `QBITTORRENT_WEBUI_USER` | `admin` | WebUI username |
| `QBITTORRENT_WEBUI_PASSWORD` | *(auto-generated)* | WebUI pwd, see note |

Username:- `admin` (or the value of `QBITTORRENT_WEBUI_USER`)

Password (if `QBITTORRENT_WEBUI_PASSWORD` not set):-

On first run a random password is auto-generated and shown in
`/config/supervisord.log`. Look for a line like:

```text
[info] QBITTORRENT_WEBUI_PASSWORD not set, auto-generated password: AbCdEfGh1
```

On **first run** (no config yet), set `-e QBITTORRENT_WEBUI_PASSWORD=<your password>`
to use your own password instead of an auto-generated one.

On **subsequent runs** the env var is only used for API authentication
(required when `GLUETUN_INCOMING_PORT=yes`). It will NOT overwrite whatever
password is already stored in the config — that can only be changed from
inside the WebUI under Options → Web UI → Authentication.

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
    -e ENABLE_STARTUP_SCRIPTS=no \
    -e DEBUG=false \
    -e UMASK=000 \
    -e WEBUI_PORT=8080 \
    -e PUID=0 \
    -e PGID=0 \
    binhex/arch-qbittorrent
```

### WebUI notes

#### Port

Due to issues with CSRF and port mapping, should you require to alter the port
for the webui you need to change both sides of the -p 8080 switch AND set the
WEBUI_PORT variable to the new port.

#### Password

The env var `QBITTORRENT_WEBUI_PASSWORD` is used for two things:
1. **First run** — hashed and written to the config as the initial password
2. **All runs** — used for API authentication (when `GLUETUN_INCOMING_PORT=yes`)

Once a password hash exists in the config (whether auto-generated or user-set),
**it is never overwritten** by the env var. To change your password, use the
WebUI under Options → Web UI → Authentication.

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
