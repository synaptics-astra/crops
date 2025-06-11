# ubuntu-22.04-base
# Copyright (C) 2020-2021 Intel Corporation
# Copyright (C) 2022 Konsulko Group
#
# SPDX-License-Identifier: GPL-2.0-only
#

FROM ubuntu:22.04

# begin change from Synaptics
# reason: add metadata for GitHub
LABEL org.opencontainers.image.title=CROPS
LABEL org.opencontainers.image.description="Synaptics Astra CROPS container"
# end change from Synaptis

# begin change from Synaptics
# reason: only this target platform is supported
# ARG TARGETPLATFORM
ARG TARGETPLATFORM linux/amd64
# end change from Synaptis

# begin change from Synaptics
# reason: no need to download external sources
# added dumb-init to the list below
# end change from Synaptics

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        dumb-init \
        gawk \
        wget \
        git-core \
        subversion \
        diffstat \
        unzip \
        sysstat \
        texinfo \
        build-essential \
        chrpath \
        socat \
        python3 \
        python3-pip \
        python3-pexpect \
        xz-utils  \
        locales \
        cpio \
        screen \
        tmux \
        sudo \
        iputils-ping \
        python3-git \
        python3-jinja2 \
        libegl1-mesa \
        libsdl1.2-dev \
        pylint \
        xterm \
        iproute2 \
        fluxbox \
        tightvncserver \
        lz4 \
        zstd \
        file && \
    case ${TARGETPLATFORM} in \
        "linux/amd64") \
            DEBIAN_FRONTEND=noninteractive apt-get install -y \
                gcc-multilib \
                g++-multilib \
            ;; \
    esac && \
    cp -af /etc/skel/ /etc/vncskel/ && \
    echo "export DISPLAY=1" >>/etc/vncskel/.bashrc && \
    mkdir  /etc/vncskel/.vnc && \
    echo "" | vncpasswd -f > /etc/vncskel/.vnc/passwd && \
    chmod 0600 /etc/vncskel/.vnc/passwd && \
    useradd -U -m yoctouser && \
    /usr/sbin/locale-gen en_US.UTF-8    

# begin change from Synaptics
# reason: use pre-packaged version above
# COPY build-install-dumb-init.sh /
# RUN  bash /build-install-dumb-init.sh && \
#     rm /build-install-dumb-init.sh && \
#     apt-get clean
# end change from Synaptics

USER yoctouser
WORKDIR /home/yoctouser
CMD /bin/bash

# Copyright (C) 2015-2016 Intel Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Since this Dockerfile is used in multiple images, force the builder to
# specify the BASE_DISTRO. This should hopefully prevent accidentally using
# a default, when another distro was desired.

# begin change from Synaptics
# reason: no need to specify this as we concatenate the two dockerfiles
#ARG BASE_DISTRO=SPECIFY_ME

#FROM crops/yocto:$BASE_DISTRO-base
# end change from Synaptics

USER root

# begin change from Synaptics
# reason: ensure we use a fixed version of the files
#ADD https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_useradd.sh  \
#        https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_groupadd.sh \
#        https://raw.githubusercontent.com/crops/extsdk-container/master/usersetup.py \
#        /usr/bin/
COPY restrict_useradd.sh restrict_groupadd.sh usersetup.py /usr/bin/
# end change from Synaptics

COPY distro-entry.sh poky-entry.py poky-launch.sh /usr/bin/
COPY sudoers.usersetup /etc/

# For ubuntu, do not use dash.
# RUN which dash &> /dev/null && (\
#    echo "dash dash/sh boolean false" | debconf-set-selections && \
#    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash) || \
#    echo "Skipping dash reconfigure (not applicable)"

# We remove the user because we add a new one of our own.
# The usersetup user is solely for adding a new user that has the same uid,
# as the workspace. 70 is an arbitrary *low* unused uid on debian.
RUN userdel -r yoctouser && \
    mkdir /home/yoctouser && \
    groupadd -g 70 usersetup && \
    useradd -N -m -u 70 -g 70 usersetup && \
    chmod 755 /usr/bin/usersetup.py \
        /usr/bin/poky-entry.py \
        /usr/bin/poky-launch.sh \
        /usr/bin/restrict_groupadd.sh \
        /usr/bin/restrict_useradd.sh && \
    echo "#include /etc/sudoers.usersetup" >> /etc/sudoers

USER usersetup
ENV LANG=en_US.UTF-8

ENTRYPOINT ["/usr/bin/distro-entry.sh", "/usr/bin/dumb-init", "--", "/usr/bin/poky-entry.py"]
