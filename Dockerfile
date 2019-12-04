# Docker file is based on: https://bitbucket.org/networkoptix/nx_open_integrations/src/default/docker/Dockerfile

# Use latest Ubuntu LTS version
FROM ubuntu:latest

# Latest VMS versions are listed here:
# https://dwspectrum.digital-watchdog.com/download/linux
# https://nxvms.com/download/linux
ARG download_url="http://updates.networkoptix.com/digitalwatchdog/29990/linux/dwspectrum-server-4.0.0.29990-linux64.deb"
ARG download_version="4.0.0.29990"

# systemd needs to know we are running in docker
ENV container=docker \
# Prevent EULA and confirmation prompts in installers
    DEBIAN_FRONTEND=noninteractive \
# NxWitness or DWSpectrum
    COMPANY_NAME="digitalwatchdog"

LABEL name="DWSpectrum" \
    version=${download_version} \
    description="DW Spectrum IPVMS Docker" \
    maintainer="Pieter Viljoen <ptr727@users.noreply.github.com>"

# Install dependencies
RUN apt-get update \
    && apt-get install --yes \
# Install wget so we can download the installer
        wget \
# Install systemd to use systemctl
        systemd \
# Install gdb for crash handling (it is used but not included in the deb dependencies)
        gdb \
# Install binutils for patching cloud host (from nxwitness docker)
        binutils \
# Install lsb-release used as a part of install scripts inside the deb package (from nxwitness docker)
        lsb-release \
# Install nano and mc for making navigating the container easier
        nano mc \
# Download the DEB installer file    
    && wget -nv -O ./vms_server.deb ${download_url} \
# Why are the timers are being removed in the Nx docker file?
    && find /etc/systemd -name '*.timer' | xargs rm -v \
# Set the systemd run target
    && systemctl set-default multi-user.target \
# Install the DEB installer file
    && apt-get install --yes \
        ./vms_server.deb \
# Cleanup    
    && rm -rf ./vms_server.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Signal systemd to stop
STOPSIGNAL SIGRTMIN+3

# Set the systemd entry point
ENTRYPOINT ["/sbin/init", "--log-target=journal"]

# Expose port 7001
EXPOSE 7001

# Create mapped volumes
# The VMS appears to pick a random volume for media storage
# We are not currently using /config
VOLUME /media /opt/digitalwatchdog/mediaserver/var /opt/digitalwatchdog/mediaserver/etc
