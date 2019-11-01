FROM python:3.7-alpine
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-train}

ENV USER_ID ${USER_ID:-45000}
ENV GROUP_ID ${GROUP_ID:-45000}

COPY files/requirements.txt /requirements.txt
ADD http://tarballs.openstack.org/requirements/requirements-stable-${VERSION}.tar.gz /requirements.tar.gz

RUN apk add --no-cache --virtual .build-deps \
      build-base \
      libffi-dev \
      openssl-dev \
      python3-dev \
    && apk add --no-cache \
      dumb-init \
    && mkdir /requirements \
    && tar xzf /requirements.tar.gz -C /requirements --strip-components=1 \
    && rm -rf /requirements.tar.gz \
    && while read -r package; do \
         grep -q "$package" /requirements/upper-constraints.txt && \
         echo "$package" >> /packages.txt; \
       done < /requirements.txt \
    && pip3 --no-cache-dir install -c /requirements/upper-constraints.txt -r /packages.txt \
    && pip3 --no-cache-dir install -c /requirements/upper-constraints.txt ospurge \
    && rm -rf /requirements \
      /requirements.txt \
      /packages.txt \
    && apk del .build-deps \
    && openstack complete > /osc.bash_completion

RUN addgroup -g $GROUP_ID dragon \
    && adduser -D -u $USER_ID -G dragon dragon \
    && mkdir /configuration \
    && chown -R dragon: /configuration

USER dragon
WORKDIR /configuration

VOLUME ["/configuration"]

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["openstack"]
