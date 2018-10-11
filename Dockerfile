ARG UBUNTU_RELEASE=16.04
FROM ubuntu:${UBUNTU_RELEASE}
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-queens}

ENV DEBIAN_FRONTEND noninteractive

ENV USER_ID ${USER_ID:-45000}
ENV GROUP_ID ${GROUP_ID:-45000}

USER root

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        git \
        software-properties-common \
        python-pip \
    && add-apt-repository cloud-archive:$VERSION \
    && apt update

RUN apt-cache search --names-only 'python-.*client$' | grep -i OpenStack | awk '{print $1 }' | xargs apt install -y
RUN for package in python-cloudkittyclient python-congressclient python-ironic-inspector-client python-karborclient python-magnumclient python-monascaclient python-muranoclient python-neutronclient; do apt install -y $package; done

# NOTE(berendt): pankoclient is not yet part of the ubuntu cloud archive
RUN pip install pankoclient

RUN pip install git+https://git.openstack.org/openstack/ospurge

RUN groupadd -g $GROUP_ID dragon \
    && useradd -g dragon -u $USER_ID -m -d /home/dragon dragon

RUN apt clean \
    && mkdir /configuration \
    && chown -R dragon: /configuration \
    && rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/*

USER dragon
WORKDIR /configuration

VOLUME ["/configuration"]

ENTRYPOINT ["openstack"]
