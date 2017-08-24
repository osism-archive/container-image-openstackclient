# This file is subject to the terms and conditions defined in file 'LICENSE',
# which is part of this repository.

FROM ubuntu:16.04
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-ocata}

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
    && apt-get install -y \
        python-openstackclient \
        python-heatclient \
    && groupadd -g $GROUP_ID dragon \
    && useradd -g dragon -u $USER_ID -m -d /home/dragon dragon \
    && apt-get clean \
    && mkdir /credentials \
    && rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/*

USER dragon
WORKDIR /credentials

VOLUME ["/credentials"]

CMD ["/run.sh"]
