<!-- prettier-ignore-start -->
[comment]: # (
SPDX-License-Identifier: MIT
)

[comment]: # (
SPDX-FileCopyrightText: 2017-2021 Carles Fernandez-Prades <carles.fernandez@cttc.es>
)
<!-- prettier-ignore-end -->

# docker-pybombs-gnsssdr

[![REUSE status](https://api.reuse.software/badge/github.com/carlesfernandez/docker-pybombs-gnsssdr)](https://api.reuse.software/info/github.com/carlesfernandez/docker-pybombs-gnsssdr)

This repository contains a Dockerfile that creates a
[Docker](https://www.docker.com/) image with [GNSS-SDR](https://gnss-sdr.org)
and its dependencies installed via
[PyBOMBS](https://github.com/gnuradio/pybombs). This includes
[GNU Radio](https://gnuradio.org/) and drivers for a wide range of RF front-ends
through [UHD](https://github.com/EttusResearch/uhd),
[gr-osmosdr](https://osmocom.org/projects/gr-osmosdr/wiki/GrOsmoSDR) and
[gr-iio](https://github.com/analogdevicesinc/gr-iio).

This image uses [baseimage-docker](https://github.com/phusion/baseimage-docker),
a special Docker image that is configured for correct use within Docker
containers. It is Ubuntu, plus:

- Modifications for Docker-friendliness.
- Administration tools that are especially useful in the context of Docker.
- Mechanisms for easily running multiple processes, without violating the Docker
  philosophy.
- Reduced footprint on RAM.

If you still have not done so,
[install Docker](https://docs.docker.com/get-started/#set-up-your-docker-environment)
and verify your installation before proceeding to use or build the Docker image.

## Pull docker image

You can download (pull) the image from the Docker Hub via following command:

     $ docker pull carlesfernandez/docker-pybombs-gnsssdr

## Run docker image

Run:

    $ docker run -it carlesfernandez/docker-pybombs-gnsssdr

### Run with access to a folder in the host machine

Maybe you want to include a local folder with GNSS raw data to process in your
container, or to extract output files generated during its execution. You can do
that by running the container as:

    $ docker run -it -v /home/user/data:/data carlesfernandez/docker-pybombs-gnsssdr

This will mount the `/home/user/data` folder in the host machine on the `/data`
folder inside the container, with read and write permissions.

### Run with graphical environment:

- **On GNU/Linux host machines**

  Install the X11 server utilities in the host machine:

  - Debian: `apt-get install x11-xserver-utils`
  - Ubuntu: `apt-get install x11-xserver-utils`
  - Arch Linux: `pacman -S xorg-xhost`
  - Kali Linux: `apt-get install x11-xserver-utils`
  - CentOS: `yum install xorg-xhost`
  - Fedora: `dnf install xorg-xhost`
  - Raspbian: `apt-get install x11-xserver-utils`

  Each time you want to use the graphical environment, adjust the permission of
  the X server in the host by the following command:

      $ xhost +local:root

  Then run the container with:

      $ docker run -e DISPLAY=$DISPLAY -v $HOME/.Xauthority:/root/.Xauthority \
      --net=host -it carlesfernandez/docker-pybombs-gnsssdr

  In case you want to revoke the granted permission:

      $ xhost -local:root

- **On macOS host machines**

  Do this once:

  - Install the latest [XQuartz](https://www.xquartz.org/) version and run it.
  - Activate the option
    "[Allow connections from network clients](https://blogs.oracle.com/oraclewebcentersuite/running-gui-applications-on-native-docker-containers-for-mac)"
    in XQuartz settings.
  - Quit and restart XQuartz to activate the setting.

  Each time you want to use the graphical environment, type in the host machine
  (with XQuartz already running):

      $ xhost + 127.0.0.1

  Then run the container with:

      $ docker run -e DISPLAY=host.docker.internal:0 -v $HOME/.Xauthority:/root/.Xauthority \
      --net=host -it carlesfernandez/docker-pybombs-gnsssdr

- **Test it!**

  In the container:

      root@ubuntu:/home# gnuradio-companion

## Build docker image

This step is not needed if you have pulled the docker image. If you want to
build an updated Docker image on your own, go to the repository root folder and
run the following command:

     $ docker build -t carlesfernandez/docker-pybombs-gnsssdr .

You can change the tag name `carlesfernandez/docker-pybombs-gnsssdr` at your own
preference.

## Copyright and License

Copyright: &copy; 2017-2021 Carles Fern&aacute;ndez-Prades,
[CTTC](https://www.cttc.cat). All rights reserved.

The content of this repository is released under the [MIT](./LICENSE) license.

## Acknowledgements

This work was partially supported by the Spanish Ministry of Science,
Innovation, and Universities through the Statistical Learning and Inference for
Large Dimensional Communication Systems (ARISTIDES, RTI2018-099722-B-I00)
project.
