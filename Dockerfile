ARG UBUNTU_RELEASE=18.04
FROM ubuntu:${UBUNTU_RELEASE}
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-train}

ENV DEBIAN_FRONTEND noninteractive

ENV USER_ID ${USER_ID:-45000}
ENV GROUP_ID ${GROUP_ID:-45000}

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        dumb-init \
        gpg-agent \
        git \
        locales \
        software-properties-common \
        python3-pip \
    && add-apt-repository cloud-archive:$VERSION \
    && apt-get update \
    && apt-cache search --names-only 'python3-.*client$' | grep -i OpenStack | awk '{print $1 }' | xargs apt-get install --no-install-recommends -y \
    && for package in \
        python3-cloudkittyclient \
        python3-congressclient \
        python3-ironic-inspector-client \
        python3-karborclient \
        python3-magnumclient \
        python3-monascaclient \
        python3-muranoclient \
        python3-neutronclient; \
      do apt-get install --no-install-recommends -y $package; done \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 --no-cache-dir install python-freezerclient
RUN pip3 --no-cache-dir install git+https://opendev.org/x/ospurge.git

RUN groupadd -g $GROUP_ID dragon \
    && useradd -g dragon -u $USER_ID -m -d /home/dragon dragon \
    && mkdir /configuration \
    && chown -R dragon: /configuration

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get clean \
    && apt-get autoremove --yes \
    && apt-get purge -y lib*-dev \
    && rm -rf \
      /var/tmp/*

USER dragon
WORKDIR /configuration

VOLUME ["/configuration"]

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["openstack"]
