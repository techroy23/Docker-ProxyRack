## ProxyRack Docker Image

A minimal Alpine based Docker image for running the **ProxyRack**.

## Links
| DockerHub | GitHub | Invite |
|----------|----------|----------|
| [![Docker Hub](https://img.shields.io/badge/ㅤ-View%20on%20Docker%20Hub-blue?logo=docker&style=for-the-badge)](https://hub.docker.com/r/techroy23/docker-proxyrack) | [![GitHub Repo](https://img.shields.io/badge/ㅤ-View%20on%20GitHub-black?logo=github&style=for-the-badge)](https://github.com/techroy23/Docker-ProxyRack) | [![Invite Link](https://img.shields.io/badge/ㅤ-Join%20ProxyRack%20Now-brightgreen?logo=linktree&style=for-the-badge)](https://peer.proxyrack.com/ref/zvc6oadgzudfr7zvsczleq8amea6ylwgwkej5itc) |

## Features
- Lightweight Alpine Linux base image.
- Configurable environment variable (`TOKEN`, `API_KEY`, `DEVICE_NAME`).
- supported arch: `amd64`.
- Auto‑update support with `--pull=always`.

## Usage
- Before running the container, increase socket buffer sizes (required for high‑throughput streaming).
- To make these settings persistent across reboots, add them to /etc/sysctl.conf or a drop‑in file under /etc/sysctl.d/.

```bash
sudo sysctl -w net.core.rmem_max=8000000
sudo sysctl -w net.core.wmem_max=8000000
```

## Use this command to generate your token. each instance should have a unique token
```bash
cat /dev/urandom | LC_ALL=C tr -dc 'A-F0-9' | dd bs=1 count=64 2>/dev/null && echo
```

## Environment variables
| Variable | Requirement | Description |
|----------|-------------|-------------|
| `TOKEN` | Required    | Your generated ProxyRack Token. Container exits if not provided. |
| `API_KEY`  | Required    | Get your API key here <a href="https://peer.proxyrack.com/api-doc">https://peer.proxyrack.com/api-doc</a>. Container exits if not provided. |
| `DEVICE_NAME`  | Required    | Alphanumeric A-Z,a-z,0-9. Container exits if not provided. |

## Run
```bash
docker run -d \
  --name=ProxyRack \
  --pull=always \
  --restart=always \
  --privileged \
  --log-driver=json-file \
  --log-opt max-size=5m \
  --log-opt max-file=3 \
  -e TOKEN=Your-TOKEN-Here \
  -e API_KEY=Your-API-Here \
  -e DEVICE_NAME=Your-Device-Name-Here \
  techroy23/docker-proxyrack:latest
```

## Invite Link
### https://peer.proxyrack.com/ref/zvc6oadgzudfr7zvsczleq8amea6ylwgwkej5itc
