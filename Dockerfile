ARG UBUNTU_RELEASE=18.04
FROM ubuntu:${UBUNTU_RELEASE}
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-stein}

ENV DEBIAN_FRONTEND noninteractive

ENV USER_ID ${USER_ID:-45000}
ENV GROUP_ID ${GROUP_ID:-45000}

USER root

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        git \
        locales \
        software-properties-common \
        python-pip \
    && add-apt-repository cloud-archive:$VERSION \
    && apt update

RUN apt-cache search --names-only 'python-.*client$' | grep -i OpenStack | awk '{print $1 }' | xargs apt install -y
RUN for package in python-cloudkittyclient python-congressclient python-ironic-inspector-client python-karborclient python-magnumclient python-monascaclient python-muranoclient python-neutronclient; do apt install -y $package; done
RUN apt-get remove --yes python-senlinclient python-tuskarclient

RUN pip --no-cache-dir install python-freezerclient
RUN pip --no-cache-dir install pankoclient

RUN pip --no-cache-dir install git+https://git.openstack.org/openstack/ospurge

RUN groupadd -g $GROUP_ID dragon \
    && useradd -g dragon -u $USER_ID -m -d /home/dragon dragon

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt clean \
    && mkdir /configuration \
    && chown -R dragon: /configuration \
    && apt-get purge -y lib*-dev \
    && rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/*

USER dragon
WORKDIR /configuration

VOLUME ["/configuration"]

ENTRYPOINT ["openstack"]
