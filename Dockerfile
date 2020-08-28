#use latest compatible debian version from group resin.io as base image
#
# use balenalib/raspberry-pi-debian:buster  for Raspberry 1, Zero, Zero W
# use balenalib/armv7hf-debian:buster for Raspberry 2,3,4
FROM balenalib/raspberry-pi-debian:buster


#dynamic build arguments coming from the /hook/build file
ARG BUILD_DATE
ARG VCS_REF

#metadata labels
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/schreinerman/rpi-nodered-docker" \
      org.label-schema.vcs-ref=$VCS_REF

#version
ENV IOEXPERT_NODERED_VERSION 1.1.0

#labeling
LABEL maintainer="info@io-expert.com" \
      version=$IOEXPERT_NODERED_VERSION \
      description="Node-RED for Raspberry Pi"

#copy files
COPY "./init.d/*" /etc/init.d/ 

#do installation
RUN  apt-get update \
    && apt-get install curl build-essential python-dev libstdc++6:armhf \
#install node.js
    && curl -sL https://unofficial-builds.nodejs.org/download/release/v12.18.3/node-v12.18.3-linux-armv6l.tar.gz -o /tmp/node-v12.18.3-linux-armv6l.tar.gz  \
    && tar -C /tmp/ -zxvf  /tmp/node-v12.18.3-linux-armv6l.tar.gz \
    && sudo cp -R /tmp/node-v12.18.3-linux-armv6l/* /usr/local \
    && rm /tmp/node-v12.18.3-linux-armv6l.tar.gz \
    && rm -R /tmp/node-v12.18.3-linux-armv6l \
    && export PATH=$PATH:/usr/local/bin \
#install Node-RED
    && npm install -g --unsafe-perm node-red \
    && npm install -g --unsafe-perm node-red-contrib-uibuilder \
    && npm install -g --unsafe-perm node-red-dashboard \
    && npm install -g --unsafe-perm node-red-contrib-ui-artless-gauge \
    && npm install -g --unsafe-perm node-red-contrib-ui-state-trail \
    && npm install -g --unsafe-perm node-red-contrib-ui-level \
    && npm install -g --unsafe-perm node-red-contrib-ui-value-trail \
    && npm install -g --unsafe-perm node-red-contrib-ui-value-trail \
    && npm install -g --unsafe-perm node-red-contrib-ui-led \
    && npm install -g --unsafe-perm npm node-red-contrib-modbus \
    && npm install -g --unsafe-perm npm node-red-contrib-modbustcp \
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
