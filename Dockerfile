ARG UBUNTU_RELEASE=18.04
FROM ubuntu:${UBUNTU_RELEASE}
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-train}

ENV DEBIAN_FRONTEND noninteractive

ENV USER_ID ${USER_ID:-45000}
ENV GROUP_ID ${GROUP_ID:-45000}

USER root

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        dumb-init \
        git \
        locales \
        software-properties-common \
        python3-pip \
    && add-apt-repository cloud-archive:$VERSION \
    && apt update

RUN apt-cache search --names-only 'python3-.*client$' | grep -i OpenStack | awk '{print $1 }' | xargs apt install -y
RUN for package in \
        python3-cloudkittyclient \
        python3-congressclient \
        python3-ironic-inspector-client \
        python3-karborclient \
        python3-magnumclient \
        python3-monascaclient \
        python3-muranoclient \
        python3-neutronclient; \
    do apt install -y $package; done

RUN pip3 --no-cache-dir install python-freezerclient
RUN pip3 --no-cache-dir install git+https://opendev.org/x/ospurge.git

RUN groupadd -g $GROUP_ID dragon \
    && useradd -g dragon -u $USER_ID -m -d /home/dragon dragon

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt clean \
    && apt autoremove --yes \
    && mkdir /configuration \
    && chown -R dragon: /configuration \
    && apt-get purge -y lib*-dev \
    && rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/*

USER dragon
WORKDIR /configuration

VOLUME ["/configuration"]

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["openstack"]
