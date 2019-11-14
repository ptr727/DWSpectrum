# DW Spectrum IPVMS Docker

[DW Spectrum IPVMS](https://digital-watchdog.com/productdetail/DW-Spectrum-IPVMS/) is the US version of [Network Optix Nx Witness VMS](https://www.networkoptix.com/nx-witness/).  
The Docker configuration is based on the [NetworkOptix Docker](https://bitbucket.org/networkoptix/nx_open_integrations/src/default/docker/) project.  
Inspiration was taken from [The Home Repot Docker](hhttps://github.com/thehomerepot/dwspectrum) project.  
Using [LinuxServer.io Ubuntu:Bionic](https://hub.docker.com/r/lsiobase/ubuntu) base image.  

## License

![GitHub](https://img.shields.io/github/license/ptr727/DWSpectrum)  

## Build Status

![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/ptr727/DWSpectrum)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ptr727/DWSpectrum)  
Pull from [Docker Hub](https://hub.docker.com/r/ptr727/DWSpectrum)  
Code at [GitHub](https://github.com/ptr727/DWSpectrum)

## Usage

### Docker Run Example

```docker
docker run -d \
--name=dwspectrum \
--restart=unless-stopped \
--net=host \
-e PUID=1000 -e PGID=1000 \
-e TZ=Americas/Los_Angeles \
-v /appdata/dwspectrum:/config \
-v /media/archive:/archive \
ptr727/dwspectrum
```

### Docker Compose Example

```yaml
version: "3.7"

services:
  dwspectrum:
    image: dwspectrum_docker
    container_name: dwspectrum_test
    hostname: dwspectrum_test_host
    domainname: home.insanegenius.net
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Americas/Los_Angeles
    build: .
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
      - ./.mount/media:/config/DW Spectrum Media
      - ./.mount/config/:/opt/digitalwatchdog/mediaserver/var
    tmpfs:
      - /run
      - /run/lock
      - /tmp
    restart: unless-stopped
    network_mode: host
    ports:
      - 7001:7001
```

## User and Group Identifiers

Use a UID and GUID that has rights on the the mapped data volumes. See the [LSIO docs](https://docs.linuxserver.io/general/understanding-puid-and-pgid) for more details.  
It is a best practice to not run as root.

## Notes

- Using the lsiobase/ubuntu:xenial base image results in an [systemd-detect-virt error](https://github.com/systemd/systemd/issues/8111).
- Using the lsiobase images allows us to specify PUID, GUID, and TZ environment variables, ideal when using UnRaid, and not running as root.

## TODO

- Work around systemd.
  - `wget -O mediaserver.deb "https://digital-watchdog.com/forcedown?file_path=_gendownloads/70b537f9-c2ae-4d5b-9ee1-519003049542/&file_name=dwspectrum-server-4.0.0.29990-linux64.deb&file=OGR6MElZbXpxWEs2TXU1cHpKYXR1U1R0THN1THpGdzlyb3QveE95dHhCTT0="`
  - `dpkg-deb -x ./mediaserver.deb ./mediaserver`
