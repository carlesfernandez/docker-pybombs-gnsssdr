# Install GNSS-SDR and its dependencies using PyBOMBS

# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:master
MAINTAINER carles.fernandez@cttc.es

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Set prefix variables
ENV PyBOMBS_prefix myprefix
ENV PyBOMBS_init /pybombs

# Update apt-get
RUN apt-get update -qq -y

# Install PyBOMBS dependencies
RUN apt-get install -qq -y \
        python-pip \
        python-yaml \
        python-apt \
        git

# Install PyBOMBS
RUN pip install --upgrade pip
RUN pip install git+https://github.com/gnuradio/pybombs.git

# Apply a configuration
RUN pybombs auto-config

# Install dependencies not available in PyBOMBS
RUN apt-get install --fix-missing -qq -y \
        libmatio-dev \
        libgnutls-openssl-dev swig nano

# Add list of default recipes
RUN pybombs recipes add-defaults

# Customize configuration of some recipes
RUN echo "vars:\n  config_opt: \"-DENABLE_OSMOSDR=ON -DENABLE_FMCOMMS2=ON -DENABLE_PLUTOSDR=ON -DENABLE_AD9361=ON -DENABLE_RAW_UDP=ON -DENABLE_PACKAGING=ON -DENABLE_UNIT_TESTING=OFF\"\n" >> /root/.pybombs/recipes/gr-recipes/gnss-sdr.lwr
RUN sed -i '/gitbranch/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/vars/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/config_opt/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/ssl/d' /root/.pybombs/recipes/gr-recipes/apache-thrift.lwr
RUN echo "gitbranch: next\n" >> /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN echo "vars:\n  config_opt: \"-DENABLE_GR_AUDIO=OFF -DENABLE_GR_COMEDI=OFF -DENABLE_GR_DIGITAL=OFF -DENABLE_DOXYGEN=OFF -DENABLE_GR_DTV=OFF -DENABLE_GR_FEC=OFF -DENABLE_GR_TRELLIS=OFF -DENABLE_GR_VOCODER=OFF -DENABLE_GR_NOAA=OFF -DENABLE_GR_VIDEO_SDL=OFF -DENABLE_GR_PAGER=OFF -DENABLE_GR_WAVELET=OFF -DENABLE_GR_ANALOG=ON -DENABLE_GR_FFT=ON -DENABLE_GR_FILTER=ON -DENABLE_GRC=ON\"\n" >> /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/gitrev/d' /root/.pybombs/recipes/gr-recipes/gr-iio.lwr
RUN echo "gitbranch: master\n" >> /root/.pybombs/recipes/gr-recipes/gr-iio.lwr

# Setup environment
RUN pybombs prefix init ${PyBOMBS_init} -a ${PyBOMBS_prefix} -R gnuradio-default
RUN echo "source "${PyBOMBS_init}"/setup_env.sh" > /root/.bashrc

RUN . ${PyBOMBS_init}/setup_env.sh
RUN pybombs -p ${PyBOMBS_prefix} -v install gr-osmosdr
RUN pybombs -p ${PyBOMBS_prefix} -v install gr-iio
RUN pybombs -p ${PyBOMBS_prefix} -v install libpcap

RUN ldconfig
ENV APPDATA /root
RUN pybombs -p ${PyBOMBS_prefix} -v install gnss-sdr && rm -rf ${PyBOMBS_init}/src/*
RUN ldconfig
RUN . ${PyBOMBS_init}/setup_env.sh && ${PyBOMBS_init}/bin/volk_profile -v 8111
RUN . ${PyBOMBS_init}/setup_env.sh && ${PyBOMBS_init}/bin/volk_gnsssdr_profile

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /home
CMD ["bash"]
