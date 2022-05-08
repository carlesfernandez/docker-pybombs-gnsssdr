# SPDX-FileCopyrightText: 2017-2021, Carles Fernandez-Prades <carles.fernandez@cttc.es>
# SPDX-License-Identifier: MIT
#
# Install GNSS-SDR and its dependencies using PyBOMBS
#
# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/releases
# for a list of version numbers.
FROM phusion/baseimage:focal-1.2.0
LABEL version="2.0" description="GNSS-SDR image built with PyBOMBS" maintainer="carles.fernandez@cttc.es"

# Set prefix variables
ENV PyBOMBS_prefix myprefix
ENV PyBOMBS_init /pybombs

# Update apt-get and install some dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && apt-get install --fix-missing -y --no-install-recommends \
  apt-utils=2.0.6 \
  automake=1:1.16.1-4ubuntu6 \
  bison=2:3.5.1+dfsg-1 \
  build-essential=12.8ubuntu1.1 \
  ca-certificates=20210119~20.04.2 \
  cmake=3.16.3-1ubuntu1 \
  doxygen=1.8.17-0ubuntu2 \
  flex=2.6.4-6.2 \
  gir1.2-gtk-3.0=3.24.20-0ubuntu1.1 \
  gir1.2-pango-1.0=1.44.7-2ubuntu4 \
  git=1:2.25.1-1ubuntu3.4 \
  gobject-introspection=1.64.1-1~ubuntu20.04.1 \
  libarmadillo-dev=1:9.800.4+dfsg-1build1 \
  libboost-all-dev=1.71.0.0ubuntu2 \
  libfftw3-dev=3.3.8-2ubuntu1 \
  libfmt-dev=6.1.2+ds-2 \
  libgflags-dev=2.2.2-1build1 \
  libgmp-dev=2:6.2.0+dfsg-4 \
  libgnutls28-dev=3.6.13-2ubuntu1.6 \
  libgoogle-glog-dev=0.4.0-1build1 \
  libgtest-dev=1.10.0-2 \
  libhidapi-dev=0.9.0+dfsg-1 \
  libmatio-dev=1.5.17-3 \
  libpcap-dev=1.9.1-3 \
  libprotobuf-dev=3.6.1.3-2ubuntu5 \
  libpugixml-dev=1.10-1 \
  libqt5opengl5-dev=5.12.8+dfsg-0ubuntu2.1 \
  libqt5svg5-dev=5.12.8-0ubuntu1 \
  libqwt-qt5-dev=6.1.4-1.1build1 \
  libsndfile1-dev=1.0.28-7ubuntu0.1 \
  libspdlog-dev=1:1.5.0-1 \
  libtool=2.4.6-14 \
  libudev-dev=245.4-4ubuntu3.16 \
  libusb-1.0-0-dev=2:1.0.23-2build1 \
  libxml2-dev=2.9.10+dfsg-5ubuntu0.20.04.2 \
  libzmq3-dev=4.3.2-2ubuntu1 \
  nano=4.8-1ubuntu1 \
  pkg-config=0.29.1-0ubuntu4 \
  protobuf-compiler=3.6.1.3-2ubuntu5 \
  pybind11-dev=2.4.3-2build2 \
  python3-apt=2.0.0ubuntu0.20.04.7 \
  python3-click-plugins=1.1.1-2 \
  python3-click=7.0-3 \
  python3-dev=3.8.2-0ubuntu2 \
  python3-gi-cairo=3.36.0-1 \
  python3-gi=3.36.0-1 \
  python3-lxml=4.5.0-1ubuntu0.5 \
  python3-mako=1.1.0+ds1-1ubuntu2 \
  python3-matplotlib=3.1.2-1ubuntu4 \
  python3-numpy=1:1.17.4-5ubuntu3 \
  python3-pip=20.0.2-5ubuntu1.6 \
  python3-pyqt5=5.14.1+dfsg-3build1 \
  python3-pyqtgraph=0.11.0~rc0-1 \
  python3-requests=2.22.0-2ubuntu1 \
  python3-setuptools=45.2.0-1 \
  python3-yaml=5.3.1-1 \
  python3-zmq=18.1.1-3 \
  qt5-default=5.12.8+dfsg-0ubuntu2.1 \
  swig=4.0.1-5build1 \
  wget=1.20.3-1ubuntu1 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PyBOMBS
RUN pip3 install --upgrade pip
RUN pip3 install git+https://github.com/gnuradio/pybombs.git

# Apply a configuration
RUN pybombs auto-config

# Add list of default recipes
RUN pybombs recipes add-defaults

# Customize configuration of some recipes
RUN echo "vars:\n  config_opt: \"-DENABLE_OSMOSDR=ON -DENABLE_FMCOMMS2=ON -DENABLE_PLUTOSDR=ON -DENABLE_AD9361=ON -DENABLE_RAW_UDP=ON -DENABLE_PACKAGING=ON -DENABLE_UNIT_TESTING=OFF\"\n" >> /root/.pybombs/recipes/gr-recipes/gnss-sdr.lwr \
 && echo "vars:\n  config_opt: \" -DINSTALL_LIB_DIR=\$prefix/lib\"\n" >> /root/.pybombs/recipes/gr-recipes/uhd.lwr \
 && sed -i '/gsl/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/alsa/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/vars/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/config_opt/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i 's/doxygen/doxygen\n- libiio\n- libad9361/' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && echo "vars:\n  config_opt: \"-DENABLE_GR_AUDIO=OFF -DENABLE_GR_CHANNELS=OFF -DENABLE_GR_COMEDI=OFF -DENABLE_GR_DIGITAL=OFF -DENABLE_DOXYGEN=OFF -DENABLE_GR_DTV=OFF -DENABLE_GR_FEC=OFF -DENABLE_GR_TRELLIS=OFF -DENABLE_GR_VIDEO_SDL=OFF -DENABLE_GR_VOCODER=OFF -DENABLE_GR_WAVELET=OFF -DENABLE_GR_ZEROMQ=OFF -DENABLE_GR_CTRLPORT=ON -DENABLE_GR_ANALOG=ON -DENABLE_GR_FFT=ON -DENABLE_GR_FILTER=ON -DENABLE_GRC=ON -DENABLE_GR_IIO=ON\"\n" >> /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/gr-fcdproplus/d' /root/.pybombs/recipes/gr-recipes/gr-osmosdr.lwr \
 && sed -i '/gr-iqbal/d' /root/.pybombs/recipes/gr-recipes/gr-osmosdr.lwr

ARG TZ=CET
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime

# Build and install GNU Radio via Pybombs
RUN DEBIAN_FRONTEND=noninteractive apt-get update && pybombs prefix init ${PyBOMBS_init} -a ${PyBOMBS_prefix} -R gnuradio-main && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*

# Setup environment
RUN echo "export PYTHONPATH=\"\$PYTHONPATH:/pybombs/lib/python3/dist-packages\"" >> ${PyBOMBS_init}/setup_env.sh && echo "source "${PyBOMBS_init}"/setup_env.sh" > /root/.bashrc && . ${PyBOMBS_init}/setup_env.sh
ENV PYTHONPATH /usr/lib/python3/dist-packages

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && pybombs -p ${PyBOMBS_prefix} -v install gr-osmosdr && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*

# Build and install gnss-sdr drivers via Pybombs
ENV APPDATA /root
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && pybombs -p ${PyBOMBS_prefix} -v install gnss-sdr && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*

WORKDIR /home
CMD ["bash"]
