FROM ubuntu:bionic

LABEL name="DWSpectrum" \
    version="4.0.0.29990" \
    description="DW Spectrum IPVMS Docker" \
    maintainer="Pieter Viljoen <ptr727@users.noreply.github.com>"

# Latest versions are listed here:
# https://dwspectrum.digital-watchdog.com/download/linux
# https://nxvms.com/download/linux
# Using DWSpectrum server v4.0.0.29990
ENV downloadurl="https://digital-watchdog.com/forcedown?file_path=_gendownloads/70b537f9-c2ae-4d5b-9ee1-519003049542/&file_name=dwspectrum-server-4.0.0.29990-linux64.deb&file=OGR6MElZbXpxWEs2TXU1cHpKYXR1U1R0THN1THpGdzlyb3QveE95dHhCTT0=" \
# The NxWitness and DwSpectrum apps are nearly identical, but the installer uses different folder names and different user accounts, complicating scripting
    appname="digitalwatchdog" \
# Note, I have not tested this docker setup with NxWitness
    #appname="networkoptix" \
# systemd needs to know we are running in docker
    container=docker \
# Prevent EULA and confirmation prompts in installers
    DEBIAN_FRONTEND=noninteractive

# Docker file is based on: https://bitbucket.org/networkoptix/nx_open_integrations/src/default/docker/Dockerfile
# Running systemd in a container: https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container
# TODO: Can we run systemd and use --user to run as non root?

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
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
    && wget -nv -O ./vms_server.deb ${downloadurl} \
# Why are the timers are being removed?
    && find /etc/systemd -name '*.timer' | xargs rm -v \
# Set the systemd run target
    && systemctl set-default multi-user.target \
# Install the DEB installer file
    && apt-get install -y ./vms_server.deb \
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

# Create data volumes
VOLUME /config /archive
