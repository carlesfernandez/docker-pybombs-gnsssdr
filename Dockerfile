# Install GNSS-SDR and its dependencies using PyBOMBS

# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/releases
# for a list of version numbers.
FROM phusion/baseimage:0.10.1
MAINTAINER carles.fernandez@cttc.es

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Set prefix variables
ENV PyBOMBS_prefix myprefix
ENV PyBOMBS_init /pybombs

# Update apt-get and install some dependencies
RUN apt-get update -qq -y && apt-get install --fix-missing -qq -y --no-install-recommends \
        python3-dev=3.5.1-3 \
        python3-numpy=1:1.11.0-1ubuntu1 \
        python3-scipy=0.17.0-1 \
        python3-lxml=3.5.0-1build1 \
        python3-mako=1.0.3+ds1-1ubuntu1 \
        python3-gi-cairo=3.20.0-0ubuntu1 \
        python3-pyqt5=5.5.1+dfsg-3ubuntu4 \
        python3-yaml=3.11-3build1 \
        python3-pip=8.1.1-2ubuntu0.4 \
        python3-setuptools=20.7.0-1 \
        python3-apt=1.1.0~beta1ubuntu0.16.04.2 \
        python3-requests=2.9.1-3 \
        python-lxml=3.5.0-1build1 \
        python-mako=1.0.3+ds1-1ubuntu1 \
        python-six=1.10.0-3 \
        git=1:2.7.4-0ubuntu1.4 \
        swig=3.0.8-0ubuntu3 \
        nano=2.5.3-2ubuntu2 \
        pkg-config=0.29.1-0ubuntu1 \
        automake=1:1.15-4ubuntu1 \
        gir1.2-pango-1.0=1.38.1-1 \
        gir1.2-gtk-3.0=3.18.9-1ubuntu3.3 \
        libmatio-dev=1.5.3-1 \
        libgnutls28-dev=3.4.10-4ubuntu1.4 \
        libarmadillo-dev=1:6.500.5+dfsg-1 \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PyBOMBS
RUN pip3 install --upgrade pip
RUN pip3 install git+https://github.com/gnuradio/pybombs.git

# Apply a configuration
RUN pybombs auto-config

# Add list of default recipes
RUN pybombs recipes add-defaults

# Customize configuration of some recipes
RUN echo "vars:\n  config_opt: \"-DENABLE_OSMOSDR=ON -DENABLE_FMCOMMS2=ON -DENABLE_PLUTOSDR=ON -DENABLE_AD9361=ON -DENABLE_RAW_UDP=ON -DENABLE_PACKAGING=ON -DENABLE_UNIT_TESTING=OFF\"\n" >> /root/.pybombs/recipes/gr-recipes/gnss-sdr.lwr
RUN sed -i '/alsa/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/thrift/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/pygtk/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/pycairo/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/gitbranch/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/vars/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/config_opt/d' /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/ssl/d' /root/.pybombs/recipes/gr-recipes/apache-thrift.lwr
RUN sed -i '/iqbal/d' /root/.pybombs/recipes/gr-recipes/gr-osmosdr.lwr
RUN echo "gitbranch: next\n" >> /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN echo "vars:\n  config_opt: \"-DENABLE_GR_AUDIO=OFF -DENABLE_GR_COMEDI=OFF -DENABLE_GR_DIGITAL=OFF -DENABLE_DOXYGEN=OFF -DENABLE_GR_DTV=OFF -DENABLE_GR_FEC=OFF -DENABLE_GR_TRELLIS=OFF -DENABLE_GR_VOCODER=OFF -DENABLE_GR_NOAA=OFF -DENABLE_GR_VIDEO_SDL=OFF -DENABLE_GR_PAGER=OFF -DENABLE_GR_WAVELET=OFF -DENABLE_GR_ANALOG=ON -DENABLE_GR_FFT=ON -DENABLE_GR_FILTER=ON -DENABLE_GRC=ON\"\n" >> /root/.pybombs/recipes/gr-recipes/gnuradio.lwr
RUN sed -i '/gitrev/d' /root/.pybombs/recipes/gr-recipes/gr-iio.lwr
RUN echo "gitbranch: master\n" >> /root/.pybombs/recipes/gr-recipes/gr-iio.lwr

# Setup environment
RUN apt-get update -qq -y && pybombs prefix init ${PyBOMBS_init} -a ${PyBOMBS_prefix} -R gnuradio-default && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*
RUN echo "source "${PyBOMBS_init}"/setup_env.sh" > /root/.bashrc
RUN . ${PyBOMBS_init}/setup_env.sh

# Install optional drivers via Pybombs
RUN apt-get update -qq -y && pybombs -p ${PyBOMBS_prefix} -v install gr-osmosdr && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*
RUN apt-get update -qq -y && pybombs -p ${PyBOMBS_prefix} -v install gr-iio && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*
RUN apt-get update -qq -y && pybombs -p ${PyBOMBS_prefix} -v install libpcap && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*

# Build and install gnss-sdr drivers via Pybombs
ENV APPDATA /root
RUN apt-get update -qq -y && pybombs -p ${PyBOMBS_prefix} -v install gnss-sdr && rm -rf /var/lib/apt/lists/* && rm -rf ${PyBOMBS_init}/src/*

# Run VOLK profilers
RUN . ${PyBOMBS_init}/setup_env.sh && ${PyBOMBS_init}/bin/volk_profile -v 8111
RUN . ${PyBOMBS_init}/setup_env.sh && ${PyBOMBS_init}/bin/volk_gnsssdr_profile
RUN rm -rf /tmp/* /var/tmp/*

WORKDIR /home
CMD ["bash"]
