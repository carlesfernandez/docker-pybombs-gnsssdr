# SPDX-FileCopyrightText: 2017-2025, Carles Fernandez-Prades <carles.fernandez@cttc.es>
# SPDX-License-Identifier: MIT
#
# Install GNSS-SDR and its dependencies using PyBOMBS
#
# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/releases
# for a list of version numbers.
FROM phusion/baseimage:noble-1.0.2
LABEL version="6.0" description="GNSS-SDR image built with PyBOMBS" maintainer="carles.fernandez@cttc.es"

# Set prefix variables
ENV PyBOMBS_prefix=myprefix
ENV PyBOMBS_init=/pybombs

# Update apt and install some dependencies
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --fix-missing --no-install-recommends \
  apt-utils=2.7.14build2 \
  automake=1:1.16.5-1.3ubuntu1 \
  bison=2:3.8.2+dfsg-1build2 \
  build-essential=12.10ubuntu1 \
  ca-certificates=20240203 \
  cmake=3.28.3-1build7 \
  cppzmq-dev=4.10.0-1build1 \
  doxygen=1.9.8+ds-2build5 \
  flex=2.6.4-8.2build1 \
  gir1.2-gtk-3.0=3.24.41-4ubuntu1.2 \
  gir1.2-pango-1.0=1.52.1+ds-1build1 \
  git=1:2.43.0-1ubuntu7.2 \
  gobject-introspection=1.80.1-1 \
  libarmadillo-dev=1:12.6.7+dfsg-1build2 \
  libboost-all-dev=1.83.0.1ubuntu2 \
  libfftw3-dev=3.3.10-1ubuntu3 \
  libfmt-dev=9.1.0+ds1-2 \
  libgflags-dev=2.2.2-2build1 \
  libgmp-dev=2:6.3.0+dfsg-2ubuntu6.1 \
  libgnutls28-dev=3.8.3-1.1ubuntu3.3 \
  libgoogle-glog-dev=0.6.0-2.1build1 \
  libgtest-dev=1.14.0-1 \
  libhidapi-dev=0.14.0-1build1 \
  libmatio-dev=1.5.26-1build3 \
  libncurses-dev=6.4+20240113-1ubuntu2 \
  libpcap-dev=1.10.4-4.1ubuntu3 \
  libprotobuf-dev=3.21.12-8.2build1 \
  libpugixml-dev=1.14-0.1build1 \
  libqt5opengl5-dev=5.15.13+dfsg-1ubuntu1 \
  libqt5svg5-dev=5.15.13-1 \
  libqwt-qt5-dev=6.1.4-2build2 \
  libsndfile1-dev=1.2.2-1ubuntu5.24.04.1 \
  libspdlog-dev=1:1.12.0+ds-2build1 \
  libtool=2.4.7-7build1 \
  libudev-dev=255.4-1ubuntu8.6 \
  libusb-1.0-0-dev=2:1.0.27-1 \
  libxml2-dev=2.9.14+dfsg-1.3ubuntu3.2 \
  libzmq3-dev=4.3.5-1build2 \
  nano=7.2-2ubuntu0.1 \
  pkgconf=1.8.1-2build1 \
  protobuf-compiler=3.21.12-8.2build1 \
  pybind11-dev=2.11.1-2 \
  python3-apt=2.7.7ubuntu4 \
  python3-click-plugins=1.1.1-4 \
  python3-click=8.1.6-2 \
  python3-dev=3.12.3-0ubuntu2 \
  python3-gi-cairo=3.48.2-1 \
  python3-gi=3.48.2-1 \
  python3-lxml=5.2.1-1 \
  python3-mako=1.3.2-1 \
  python3-matplotlib=3.6.3-1ubuntu5 \
  python3-numpy=1:1.26.4+ds-6ubuntu1 \
  python3-pip=24.0+dfsg-1ubuntu1.1 \
  python3-pyqt5=5.15.10+dfsg-1build6 \
  python3-pyqtgraph=0.13.4-2 \
  python3-requests=2.31.0+dfsg-1ubuntu1 \
  python3-setuptools=68.1.2-2ubuntu1.1 \
  python3-yaml=6.0.1-2build2 \
  python3-zmq=24.0.1-5build1 \
  qt5-qmake=5.15.13+dfsg-1ubuntu1 \
  qtbase5-dev=5.15.13+dfsg-1ubuntu1 \
  qtbase5-dev-tools=5.15.13+dfsg-1ubuntu1 \
  swig=4.2.0-2ubuntu1 \
  vim=2:9.1.0016-1ubuntu7.8 \
  wget=1.21.4-1ubuntu4.1 \
  && apt clean && rm -rf /var/lib/apt/lists/*

# Install PyBOMBS
RUN git clone https://github.com/gnuradio/pybombs.git && cd pybombs && python3 setup.py install

# Apply a configuration
RUN pybombs auto-config

# Add list of default recipes
RUN pybombs recipes add-defaults

# Customize configuration of some recipes
RUN echo "vars:\n  config_opt: \"-DENABLE_OSMOSDR=ON -DENABLE_FMCOMMS2=ON -DENABLE_PLUTOSDR=ON -DENABLE_RAW_UDP=ON -DENABLE_ZMQ=ON -DENABLE_PACKAGING=ON -DENABLE_UNIT_TESTING=OFF\"\n" >> /root/.pybombs/recipes/gr-recipes/gnss-sdr.lwr \
  && echo "vars:\n  config_opt: \" -DINSTALL_LIB_DIR=\$prefix/lib\"\n" >> /root/.pybombs/recipes/gr-recipes/uhd.lwr \
  && sed -i '/gsl/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && sed -i '/alsa/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && sed -i '/vars/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && sed -i '/config_opt/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && sed -i 's/doxygen/doxygen\n- libiio\n- libad9361/' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && echo "vars:\n  config_opt: \"-DENABLE_GR_AUDIO=OFF -DENABLE_GR_CHANNELS=OFF -DENABLE_GR_COMEDI=OFF -DENABLE_GR_DIGITAL=OFF -DENABLE_DOXYGEN=OFF -DENABLE_GR_DTV=OFF -DENABLE_GR_FEC=OFF -DENABLE_GR_TRELLIS=OFF -DENABLE_GR_VIDEO_SDL=OFF -DENABLE_GR_VOCODER=OFF -DENABLE_GR_WAVELET=OFF -DENABLE_GR_ZEROMQ=ON -DENABLE_GR_CTRLPORT=ON -DENABLE_GR_ANALOG=ON -DENABLE_GR_FFT=ON -DENABLE_GR_FILTER=ON -DENABLE_GRC=ON -DENABLE_GR_IIO=ON\"\n" >> /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
  && sed -i '/gr-fcdproplus/d' /root/.pybombs/recipes/gr-recipes/gr-osmosdr.lwr \
  && sed -i '/gr-iqbal/d' /root/.pybombs/recipes/gr-recipes/gr-osmosdr.lwr

ARG TZ=CET
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime

# Build and install GNU Radio via Pybombs
RUN DEBIAN_FRONTEND=noninteractive apt-get update && pybombs prefix init ${PyBOMBS_init} -a ${PyBOMBS_prefix} -R gnuradio-main && apt clean && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*

# Setup environment
RUN echo "export PYTHONPATH=\"\$PYTHONPATH:/pybombs/lib/python3/dist-packages\"" >> ${PyBOMBS_init}/setup_env.sh && echo "source "${PyBOMBS_init}"/setup_env.sh" > /root/.bashrc && . ${PyBOMBS_init}/setup_env.sh
ENV PYTHONPATH=/usr/lib/python3/dist-packages

RUN DEBIAN_FRONTEND=noninteractive apt update && pybombs -p ${PyBOMBS_prefix} -v install gr-osmosdr && apt clean && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*

# Build and install gnss-sdr drivers via Pybombs
ENV APPDATA=/root
RUN DEBIAN_FRONTEND=noninteractive apt update && pybombs -p ${PyBOMBS_prefix} -v install gnss-sdr && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*

WORKDIR /home
CMD ["bash"]
