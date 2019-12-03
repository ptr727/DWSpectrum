# DW Spectrum IPVMS Docker

[DW Spectrum IPVMS](https://digital-watchdog.com/productdetail/DW-Spectrum-IPVMS/) is the US branded version of [Network Optix Nx Witness VMS](https://www.networkoptix.com/nx-witness/).  
The docker configuration is based on the [NetworkOptix Docker](https://bitbucket.org/networkoptix/nx_open_integrations/src/default/docker/) project, using an Ubuntu base image, running as systemd.  
An [alternate version](https://github.com/ptr727/DWSpectrum-LSIO) is based on a LinuxServer base image.

## License

![GitHub](https://img.shields.io/github/license/ptr727/DWSpectrum)  

## Build Status

![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/ptr727/dwspectrum)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ptr727/dwspectrum)  
Pull from [Docker Hub](https://hub.docker.com/r/ptr727/dwspectrum)  
Code at [GitHub](https://github.com/ptr727/DWSpectrum)

## Usage

### Docker Run Example

```shell
docker run -d \
  --name=dwspectrum-test-container \
  --restart=unless-stopped \
  --network=host \
  --tmpfs /run \
  --tmpfs /run/lock \
  --tmpfs /tmp \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v /.mount/media:/media \
  -v /.mount/config/etc:/opt/digitalwatchdog/mediaserver/etc \
  -v /.mount/config/var:/opt/digitalwatchdog/mediaserver/var \
  ptr727/dwspectrum
```

### Docker Compose Example

```yaml
services:
  dwspectrum:
    image: ptr727/dwspectrum
    container_name: dwspectrum-test-container
    hostname: dwspectrum-test-host
    domainname: foo.net
    build: .
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
      - ./.mount/media:/media
      - ./.mount/config/etc:/opt/digitalwatchdog/mediaserver/etc
      - ./.mount/config/var:/opt/digitalwatchdog/mediaserver/var
    tmpfs:
      - /run
      - /run/lock
      - /tmp
    restart: unless-stopped
    network_mode: host
    ports:
      - 7001:7001
```

## Notes

- The camera licenses are tied to hardware information, and this does not work well in container environments where the hardware may change.  
- The NxWitness docker setup uses systemd, which as far as I researched, and I am no expert in this specific field, is [possible](https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container/), but not recommended.

## TODO

- [Convince](https://support.networkoptix.com/hc/en-us/articles/360037973573-How-to-run-Nx-Server-in-Docker) NxWitness to:
  - Publish always up to date docker images to Docker Hub.
  - Support running as non-root, allowing us to specify the user account to run under using `user: UID:GID`, such that file permissions match the mapped data volume permissions.
  - Use the cloud account for license enforcement, not the hardware that dynamically changes in Docker environments.
- Figure out how to automatically detect when new [NxWitness](https://nxvms.com/download/linux) or [DWSpectrum](https://dwspectrum.digital-watchdog.com/download/linux) releases are published, and update the container. Possibly parsing the readme file for version information, and using a webhook to kick the build.
- Figure out how to use `--no-install-recommends` to make the image smaller. Currently we get a `OCI runtime create failed` error if it is used, probably missing some required but unspecified dependencies.
- Figure out how to create symbolic links to `/config` from `/opt/digitalwatchdog/mediaserver/` in the docker file, before the config directory is mounted.
