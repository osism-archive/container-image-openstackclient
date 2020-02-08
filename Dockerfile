ARG PYTHON_VERSION=3.7
FROM python:${PYTHON_VERSION}-alpine

ARG VERSION=latest

ARG USER_ID=45000
ARG GROUP_ID=45000

COPY files/requirements.txt /requirements.txt

RUN apk add --no-cache --virtual .build-deps \
      build-base \
      libffi-dev \
      openssl-dev \
      python3-dev \
    && apk add --no-cache \
      dumb-init \
    && if [ $VERSION = "latest" ]; then wget -P / -O requirements.tar.gz http://tarballs.openstack.org/requirements/requirements-master.tar.gz; fi \
    && if [ $VERSION != "latest" ]; then wget -P / -O requirements.tar.gz http://tarballs.openstack.org/requirements/requirements-stable-${VERSION}.tar.gz; fi \
    && mkdir /requirements \
    && tar xzf /requirements.tar.gz -C /requirements --strip-components=1 \
    && rm -rf /requirements.tar.gz \
    && while read -r package; do \
         grep -q "$package" /requirements/upper-constraints.txt && \
         echo "$package" >> /packages.txt; \
       done < /requirements.txt \
    && if [ $VERSION = "rocky" ]; then sed -i '/^python-vitrageclient/d' /requirements/upper-constraints.txt; echo 'python-vitrageclient===2.7.0' >> /requirements/upper-constraints.txt; fi \
    && if [ $VERSION = "rocky" ]; then sed -i '/^cmd2/d' /requirements/upper-constraints.txt; echo 'cmd2===0.8.9' >> /requirements/upper-constraints.txt; fi \
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

LABEL "org.opencontainers.image.documentation"="https://docs.osism.io" \
      "org.opencontainers.image.licenses"="ASL 2.0" \
      "org.opencontainers.image.source"="https://github.com/osism/docker-openstackclient" \
      "org.opencontainers.image.url"="https://www.osism.de" \
      "org.opencontainers.image.vendor"="Betacloud Solutions GmbH"
