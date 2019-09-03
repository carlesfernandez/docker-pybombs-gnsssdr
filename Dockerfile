# Install GNSS-SDR and its dependencies using PyBOMBS

# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/releases
# for a list of version numbers.
FROM phusion/baseimage:0.11
MAINTAINER carles.fernandez@cttc.es

# Set prefix variables
ENV PyBOMBS_prefix myprefix
ENV PyBOMBS_init /pybombs

# Update apt-get and install some dependencies
RUN apt-get -qq update && apt-get install --fix-missing -y --no-install-recommends \
 automake=1:1.15.1-3ubuntu2 \
 gir1.2-gtk-3.0=3.22.30-1ubuntu1 \
 gir1.2-pango-1.0=1.40.14-1 \
 git=1:2.17.1-1ubuntu0.4 \
 libarmadillo-dev=1:8.400.0+dfsg-2 \
 libgnutls28-dev=3.5.18-1ubuntu1 \
 libmatio-dev=1.5.11-1 \
 libpugixml-dev=1.8.1-7 \
 nano=2.9.3-2 \
 pkg-config=0.29.1-0ubuntu2 \
 python3-apt=1.6.2 \
 python3-dev=3.6.7-1~18.04 \
 python3-gi-cairo=3.26.1-2 \
 python3-lxml=4.2.1-1 \
 python3-mako=1.0.7+ds1-1 \
 python3-numpy=1:1.13.3-2ubuntu1 \
 python3-pip=9.0.1-2.3~ubuntu1 \
 python3-pyqt5=5.10.1+dfsg-1ubuntu2 \
 python3-requests=2.18.4-2 \
 python3-setuptools=39.0.1-2 \
 python3-yaml=3.12-1build2 \
 swig=3.0.12-1 \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PyBOMBS
RUN pip3 install --upgrade pip
RUN pip3 install git+https://github.com/gnuradio/pybombs.git

# Apply a configuration
RUN pybombs auto-config

# Add list of default recipes
RUN pybombs recipes add-defaults

# Customize configuration of some recipes
RUN echo "vars:\n  config_opt: \"-DENABLE_OSMOSDR=ON -DENABLE_FMCOMMS2=ON -DENABLE_PLUTOSDR=ON -DENABLE_AD9361=ON -DENABLE_RAW_UDP=ON -DENABLE_PACKAGING=ON -DENABLE_UNIT_TESTING=OFF -DPYTHON_EXECUTABLE=/usr/bin/python3\"\n" >> /root/.pybombs/recipes/gr-recipes/gnss-sdr.lwr \
 && echo "vars:\n  config_opt: \" -DINSTALL_LIB_DIR=\$prefix/lib -DENABLE_PYTHON3=ON\"\n" >> /root/.pybombs/recipes/gr-recipes/uhd.lwr \
 && sed -i '/cppunit/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/gsl/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/alsa/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/wxpython/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/thrift/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/pygtk/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/pycairo/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/pyqt4/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/qwt/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/gitbranch/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/vars/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/config_opt/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/ssl/d' /root/.pybombs/recipes/gr-recipes/apache-thrift.lwr \
 && sed -i '/iqbal/d' /root/.pybombs/recipes/gr-recipes/gr-osmosdr.lwr \
 && echo "gitbranch: master\n" >> /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && echo "vars:\n  config_opt: \"-DENABLE_GR_AUDIO=OFF -DENABLE_GR_CHANNELS=OFF -DENABLE_GR_COMEDI=OFF -DENABLE_GR_DIGITAL=OFF -DENABLE_DOXYGEN=OFF -DENABLE_GR_DTV=OFF -DENABLE_GR_FEC=OFF -DENABLE_GR_TRELLIS=OFF -DENABLE_GR_VIDEO_SDL=OFF -DENABLE_GR_VOCODER=OFF -DENABLE_GR_WAVELET=OFF -DENABLE_GR_ZEROMQ=OFF -DENABLE_GR_CTRLPORT=ON -DENABLE_GR_ANALOG=ON -DENABLE_GR_FFT=ON -DENABLE_GR_FILTER=ON -DENABLE_GRC=ON\"\n" >> /root/.pybombs/recipes/gr-recipes/gnuradio.lwr \
 && sed -i '/gitrev/d' /root/.pybombs/recipes/gr-recipes/gr-iio.lwr \
 && echo "gitbranch: master\n" >> /root/.pybombs/recipes/gr-recipes/gr-iio.lwr \
 && sed -i '/osmocom/d' /root/.pybombs/recipes/gr-recipes/gr-osmosdr.lwr \
 && echo "source: git+https://github.com/osmocom/gr-osmosdr.git\n" >> /root/.pybombs/recipes/gr-recipes/gr-osmosdr.lwr \
 && sed -i '/gitrev/d' /root/.pybombs/recipes/gr-recipes/libiio.lwr \
 && echo "gitrev: tags/v0.15\n" >> /root/.pybombs/recipes/gr-recipes/libiio.lwr

# Build and install GNU Radio via Pybombs
RUN apt-get -qq update && pybombs prefix init ${PyBOMBS_init} -a ${PyBOMBS_prefix} -R gnuradio-default && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*

# Setup environment
RUN echo "export PYTHONPATH=\"\$PYTHONPATH:/pybombs/lib/python3.6/dist-packages\"" >> ${PyBOMBS_init}/setup_env.sh && echo "source "${PyBOMBS_init}"/setup_env.sh" > /root/.bashrc && . ${PyBOMBS_init}/setup_env.sh

# Install optional drivers via Pybombs
RUN apt-get -qq update && pybombs -p ${PyBOMBS_prefix} -v install gr-osmosdr gr-iio libpcap && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*

# Build and install gnss-sdr drivers via Pybombs
ENV APPDATA /root
RUN apt-get -qq update && pybombs -p ${PyBOMBS_prefix} -v install gnss-sdr && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*

# Run VOLK profilers
RUN . ${PyBOMBS_init}/setup_env.sh && ${PyBOMBS_init}/bin/volk_profile -v 8111
RUN . ${PyBOMBS_init}/setup_env.sh && ${PyBOMBS_init}/bin/volk_gnsssdr_profile
RUN rm -rf /tmp/* /var/tmp/*

WORKDIR /home
CMD ["bash"]
