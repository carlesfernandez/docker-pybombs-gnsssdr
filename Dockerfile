# SPDX-FileCopyrightText: 2017-2024, Carles Fernandez-Prades <carles.fernandez@cttc.es>
# SPDX-License-Identifier: MIT
#
# Install GNSS-SDR and its dependencies using PyBOMBS
#
# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/releases
# for a list of version numbers.
FROM phusion/baseimage:jammy-1.0.2
LABEL version="4.0" description="GNSS-SDR image built with PyBOMBS" maintainer="carles.fernandez@cttc.es"

# Set prefix variables
ENV PyBOMBS_prefix myprefix
ENV PyBOMBS_init /pybombs

# Update apt-get and install some dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && apt-get install --fix-missing -y --no-install-recommends \
  apt-utils=2.4.7 \
  automake=1:1.16.5-1.3 \
  bison=2:3.8.2+dfsg-1build1 \
  build-essential=12.9ubuntu3 \
  ca-certificates=20211016 \
  cmake=3.22.1-1ubuntu1.22.04.2 \
  doxygen=1.9.1-2ubuntu2 \
  flex=2.6.4-8build2 \
  gir1.2-gtk-3.0=3.24.33-1ubuntu1 \
  gir1.2-pango-1.0=1.50.6+ds-2ubuntu1 \
  git=1:2.34.1-1ubuntu1.9 \
  gobject-introspection=1.72.0-1 \
  libarmadillo-dev=1:10.8.2+dfsg-1 \
  libboost-all-dev=1.74.0.3ubuntu7 \
  libfftw3-dev=3.3.8-2ubuntu8 \
  libfmt-dev=8.1.1+ds1-2 \
  libgflags-dev=2.2.2-2 \
  libgmp-dev=2:6.2.1+dfsg-3ubuntu1 \
  libgnutls28-dev=3.7.3-4ubuntu1.4 \
  libgoogle-glog-dev=0.5.0+really0.4.0-2 \
  libgtest-dev=1.11.0-3 \
  libhidapi-dev=0.11.2-1 \
  libmatio-dev=1.5.21-1 \
  libpcap-dev=1.10.1-4build1 \
  libprotobuf-dev=3.12.4-1ubuntu7.22.04.1 \
  libpugixml-dev=1.12.1-1 \
  libqt5opengl5-dev=5.15.3+dfsg-2ubuntu0.2 \
  libqt5svg5-dev=5.15.3-1 \
  libqwt-qt5-dev=6.1.4-2 \
  libsndfile1-dev=1.0.31-2ubuntu0.1 \
  libspdlog-dev=1:1.9.2+ds-0.2 \
  libtool=2.4.6-15build2 \
  libudev-dev=249.11-0ubuntu3.12 \
  libusb-1.0-0-dev=2:1.0.25-1ubuntu2 \
  libxml2-dev=2.9.13+dfsg-1ubuntu0.4 \
  libzmq3-dev=4.3.4-2 \
  nano=6.2-1 \
  pkg-config=0.29.2-1ubuntu3 \
  protobuf-compiler=3.12.4-1ubuntu7.22.04.1 \
  pybind11-dev=2.9.1-2 \
  python3-apt=2.3.0ubuntu2.1 \
  python3-click-plugins=1.1.1-3 \
  python3-click=8.0.3-1 \
  python3-dev=3.10.6-1~22.04 \
  python3-gi-cairo=3.42.1-0ubuntu1 \
  python3-gi=3.42.1-0ubuntu1 \
  python3-lxml=4.8.0-1build1 \
  python3-mako=1.1.3+ds1-2 \
  python3-matplotlib=3.5.1-2build1 \
  python3-numpy=1:1.21.5-1build2 \
  python3-pip=22.0.2+dfsg-1 \
  python3-pyqt5=5.15.6+dfsg-1ubuntu3 \
  python3-pyqtgraph=0.12.4-1 \
  python3-requests=2.25.1+dfsg-2 \
  python3-setuptools=59.6.0-1.2 \
  python3-yaml=5.4.1-1ubuntu1 \
  python3-zmq=22.3.0-1build1 \
  qt5-qmake=5.15.3+dfsg-2ubuntu0.2 \
  qtbase5-dev=5.15.3+dfsg-2ubuntu0.2 \
  qtbase5-dev-tools=5.15.3+dfsg-2ubuntu0.2 \
  swig=4.0.2-1ubuntu1 \
  wget=1.21.2-2ubuntu1 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PyBOMBS
RUN pip3 install --upgrade pip
RUN pip3 install git+https://github.com/gnuradio/pybombs.git

# Apply a configuration
RUN pybombs auto-config

# Add list of default recipes
RUN pybombs recipes add-defaults

# Customize configuration of some recipes
RUN echo "vars:\n  config_opt: \"-DENABLE_OSMOSDR=ON -DENABLE_FMCOMMS2=ON -DENABLE_PLUTOSDR=ON -DENABLE_AD9361=ON -DENABLE_RAW_UDP=ON -DENABLE_ZMQ=ON -DENABLE_PACKAGING=ON -DENABLE_UNIT_TESTING=OFF\"\n" >> /root/.pybombs/recipes/gr-recipes/gnss-sdr.lwr \
  && echo "vars:\n  config_opt: \" -DINSTALL_LIB_DIR=\$prefix/lib\"\n" >> /root/.pybombs/recipes/gr-recipes/uhd.lwr \
  && sed -i '/gsl/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && sed -i '/alsa/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && sed -i '/vars/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && sed -i '/config_opt/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && sed -i 's/doxygen/doxygen\n- libiio\n- libad9361/' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && echo "vars:\n  config_opt: \"-DENABLE_GR_AUDIO=OFF -DENABLE_GR_CHANNELS=OFF -DENABLE_GR_COMEDI=OFF -DENABLE_GR_DIGITAL=OFF -DENABLE_DOXYGEN=OFF -DENABLE_GR_DTV=OFF -DENABLE_GR_FEC=OFF -DENABLE_GR_TRELLIS=OFF -DENABLE_GR_VIDEO_SDL=OFF -DENABLE_GR_VOCODER=OFF -DENABLE_GR_WAVELET=OFF -DENABLE_GR_ZEROMQ=ON -DENABLE_GR_CTRLPORT=ON -DENABLE_GR_ANALOG=ON -DENABLE_GR_FFT=ON -DENABLE_GR_FILTER=ON -DENABLE_GRC=ON -DENABLE_GR_IIO=ON\"\n" >> /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && sed -i '/gr-fcdproplus/d' /root/.pybombs/recipes/gr-recipes/gr-osmosdr.lwr \
  && sed -i '/gr-iqbal/d' /root/.pybombs/recipes/gr-recipes/gr-osmosdr.lwr \
  && echo "gitbranch: main" >> /root/.pybombs/recipes/gr-recipes/libad9361.lwr

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
