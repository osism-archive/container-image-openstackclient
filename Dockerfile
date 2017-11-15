# This file is subject to the terms and conditions defined in file 'LICENSE',
# which is part of this repository.

FROM ubuntu:16.04
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-pike}

ENV DEBIAN_FRONTEND noninteractive

ENV USER_ID ${USER_ID:-45000}
ENV GROUP_ID ${GROUP_ID:-45000}

USER root

ADD files/run.sh /run.sh

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        software-properties-common \
    && add-apt-repository cloud-archive:$VERSION \
    && apt-get update \
    && apt-get install -y --ignore-missing \
      python-aodhclient \
      python-barbicanclient \
      python-ceilometerclient \
      python-cinderclient \
      python-congressclient \
      python-designateclient \
      python-glanceclient \
      python-glareclient \
      python-gnocchiclient \
      python-heatclient \
      python-ironic-inspector-client \
      python-ironicclient \
      python-keystoneclient \
      python-magnumclient \
      python-manilaclient \
      python-mistralclient \
      python-monascaclient \
      python-muranoclient \
      python-neutronclient \
      python-novaclient \
      python-openstackclient \
      python-saharaclient \
      python-senlinclient \
      python-swiftclient \
      python-tackerclient \
      python-troveclient \
      python-watcherclient \
      python-zaqarclient \
      python-zunclient \
    && groupadd -g $GROUP_ID dragon \
    && useradd -g dragon -u $USER_ID -m -d /home/dragon dragon \
    && apt-get clean \
    && mkdir /configuration \
    && rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/*

USER dragon
WORKDIR /configuration

VOLUME ["/configuration"]

ENTRYPOINT ["/run.sh"]
