# GNSS-SDR Dockerfile

This repository contains a Dockerfile that creates a [Docker](https://www.docker.com/) image with [GNSS-SDR](https://gnss-sdr.org) and its dependencies installed via [PyBOMBS](https://github.com/gnuradio/pybombs). This includes [GNU Radio](https://gnuradio.org/) and drivers for a wide range of RF front-ends through [UHD](https://github.com/EttusResearch/uhd), [gr-osmosdr](http://osmocom.org/projects/sdr/wiki/GrOsmoSDR) and [gr-iio](https://github.com/analogdevicesinc/gr-iio).

This image uses [baseimage-docker](https://github.com/phusion/baseimage-docker), a special Docker image that is configured for correct use within Docker containers. It is Ubuntu, plus:

  * Modifications for Docker-friendliness.
  * Administration tools that are especially useful in the context of Docker.
  * Mechanisms for easily running multiple processes, without violating the Docker philosophy.
  * It only consumes 9 MB of RAM.

If you still have not done so, [install Docker](https://docs.docker.com/engine/getstarted/step_one/) and [verify your installation](https://docs.docker.com/engine/getstarted/step_three/).

Pull docker image
-----------

You can download (pull) the image via following command:

     $ docker pull carlesfernandez/docker-pybombs-gnsssdr



Build docker image
-----------

Go to the repository directory and run the following command:

     $ docker build -t carlesfernandez/docker-pybombs-gnsssdr .


Run docker image
-----------
Run:

    $ docker run -it carlesfernandez/docker-pybombs-gnsssdr

Run with graphical environment:

This should work on most Linux X server machines and makes GNU Radio Companion accessible.

     $ docker run --rm -ti -e DISPLAY -v $HOME/.Xauthority:/root/.Xauthority \
     --net=host carlesfernandez/docker-pybombs-gnsssdr

Granting the Necessary permission
--------------
Above, we made the container processes interactive, forwarded our Display environment variable, mounted a volume 
for X11 unix socker. Sometimes, this will fail first and look something like this, but that's ok:

> No protocol specified
> rqt: cannot connect to X server unix: 0

We can just adjust the permission of X server host by the following command.
      $ xhost +local:root

Now, if we run the docker images, it will simply run.

P.S. In case you want to revoke the granted permission
     $ xhost -local:root