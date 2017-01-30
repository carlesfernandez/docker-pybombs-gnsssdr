# Install GNSS-SDR and its dependencies using PyBOMBS

# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.18
MAINTAINER carles.fernandez@cttc.es

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Set prefix variables
ENV PyBOMBS_prefix myprefix
ENV PyBOMBS_init /pybombs

# Update apt-get
RUN apt-get update

# Install PyBOMBS dependencies
RUN apt-get install -y \
        python-pip \
        python-yaml \
        python-apt \
        python-setuptools \
        git-core

# Install PyBOMBS
RUN pip install --upgrade pip
RUN pip install git+https://github.com/gnuradio/pybombs.git

# Add recipes to PyBOMBS
RUN pybombs recipes add gr-recipes git+https://github.com/gnuradio/gr-recipes.git
RUN pybombs recipes add gr-etcetera git+https://github.com/gnuradio/gr-etcetera.git

# Add configuration flags to GNSS-SDR recipe
RUN echo "vars:\n  config_opt: \"-DENABLE_OSMOSDR=ON\"\n" >> /root/.pybombs/recipes/gr-recipes/gnss-sdr.lwr

# Setup environment
RUN pybombs prefix init ${PyBOMBS_init} -a ${PyBOMBS_prefix} -R gnuradio-default
RUN echo "source "${PyBOMBS_init}"/setup_env.sh" > /root/.bashrc

RUN pybombs -p ${PyBOMBS_prefix} -v install gr-osmosdr
RUN . ${PyBOMBS_init}/setup_env.sh
RUN ldconfig
ENV APPDATA /root
RUN pybombs -p ${PyBOMBS_prefix} -v install gnss-sdr && rm -rf ${PyBOMBS_init}/src/*
RUN ldconfig
RUN . ${PyBOMBS_init}/setup_env.sh && ${PyBOMBS_init}/bin/volk_profile
RUN . ${PyBOMBS_init}/setup_env.sh && ${PyBOMBS_init}/bin/volk_gnsssdr_profile

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
