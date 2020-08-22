#use latest armv7hf compatible debian version from group resin.io as base image
#
# use armv5e  for Raspberry 1, Zero, Zero W
# use armv7hf for Raspberry 2,3,4
FROM balenalib/armv5e-debian:stretch


#dynamic build arguments coming from the /hook/build file
ARG BUILD_DATE
ARG VCS_REF

#metadata labels
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/schreinerman/rpi-nodered-docker" \
      org.label-schema.vcs-ref=$VCS_REF

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry)
RUN [ "cross-build-start" ]

#version
ENV IOEXPERT_NODERED_VERSION 1.0.0

#labeling
LABEL maintainer="info@io-expert.com" \
      version=$IOEXPERT_NODERED_VERSION \
      description="Node-RED for Raspberry Pi"

#copy files
COPY "./init.d/*" /etc/init.d/ 

#do installation
RUN apt-get update  \
    && apt-get install curl build-essential python-dev \
#install node.js
    && curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -  \
    && apt-get install -y nodejs  \
#install Node-RED
    && npm install -g --unsafe-perm node-red \
#clean up
    && rm -rf /tmp/* \
    && apt-get remove curl \
    && apt-get -yqq autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* 

#set the entrypoint
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#Node-RED Port
EXPOSE 1880

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]