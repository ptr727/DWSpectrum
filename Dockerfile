# Copied from:
# https://bitbucket.org/networkoptix/nx_open_integrations/src/default/docker/

# FROM ubuntu
# FROM ubuntu:xenial
# FROM ubuntu:bionic
# FROM ubuntu:latest
FROM lsiobase/ubuntu:bionic

LABEL name="DWSpectrum" \
    version="4.0.0.29990" \
    description="DW Spectrum IPVMS Docker" \
    maintainer="Pieter Viljoen <ptr727@users.noreply.github.com>"

#USER <UID>:<GID>

# https://dwspectrum.digital-watchdog.com/download/linux
# https://nxvms.com/download/linux
# v4.0.0.29990
ENV downloadurl="https://digital-watchdog.com/forcedown?file_path=_gendownloads/70b537f9-c2ae-4d5b-9ee1-519003049542/&file_name=dwspectrum-server-4.0.0.29990-linux64.deb&file=OGR6MElZbXpxWEs2TXU1cHpKYXR1U1R0THN1THpGdzlyb3QveE95dHhCTT0=" \
    appname="digitalwatchdog" \
    #appname="networkoptix" \
    container=docker \
    DEBIAN_FRONTEND=noninteractive

STOPSIGNAL SIGRTMIN+3
ENTRYPOINT ["/sbin/init", "--log-target=journal"]

RUN apt-get update \
    && apt-get install -y wget dbus systemd lsb-release binutils \
    && wget -nv -O ./mediaserver.deb ${downloadurl} \
    && apt-get install -y ./mediaserver.deb \
    && apt-get clean \
    && rm -rf ./mediaserver.deb \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/${appname}/mediaserver/var \
    && find /etc/systemd -name '*.timer' | xargs rm -v \
    && systemctl set-default multi-user.target

EXPOSE 7001
VOLUME /config /archive