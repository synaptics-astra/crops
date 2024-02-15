Synaptics Astra CROPS Container
===============================

The Synaptics CROPS, like the official CROPS container on which it is based, allows to create a standardized build
environment where to run a Yocto build of the Synatpics Astra SDK.

How to use the container
------------------------

.. highlight:: console

The container can be started from the top-level directory where the Yocto sources have been cloned as follows::

    $ docker run --rm -it -v $(pwd):$(pwd) ghcr.io/syna-astra/crops --workdir=$(pwd)

For more details on how to use this docker refer to the
`Synaptics Astra SDK documentation <http://syna-astra.github.com/doc/yocto.html>`_.

Contents of the repository
--------------------------

This directory contains a snapshot of the ubuntu-22.04 crops docker file.

This snapshot is chosen so that it is compatible with poky kirkstone.

Sources are taken from the official Yocto CROPS project:

https://github.com/crops/yocto-dockerfiles.git

    commit: 487f50da128386c58c0760fb7603d7a283b05f51

https://github.com/crops/poky-container.git

    commit: f11f23a6481fdacecb51860f4d8657e77679e90b

https://github.com/crops/extsdk-container

    commit: 5a78815d398f46eb6ffb7b9d881b0965f4eb9d82

The dockerfile is the collation of:

- dockerfiles/ubuntu/ubuntu-22.04/ubuntu-22.04-base/Dockerfile from yocto-dockerfiles
- Dockerfile from poky-container

Synaptics changes to the dockerfile are marked with comments.