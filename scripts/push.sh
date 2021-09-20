#!/usr/bin/env bash
set -x

# Available environment variables
#
# DOCKER_REGISTRY
# REPOSITORY
# VERSION

DOCKER_REGISTRY=${DOCKER_REGISTRY:-quay.io}
 REVISION=$(git rev-parse HEAD)

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

# push e.g. osism/openstackclient:wallaby
docker tag "$REPOSITORY:$REVISION" "$REPOSITORY:$VERSION"
docker push "$REPOSITORY:$VERSION"

# push e.g. osism/openstackclient:5.5.0
version=$(docker run --rm "$REPOSITORY:$VERSION" openstack --version | awk '{ print $2 }')

if DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "${REPOSITORY}:${version}" > /dev/null; then
    echo "The image ${REPOSITORY}:${version} already exists."
else
    docker tag "$REPOSITORY:$REVISION" "$REPOSITORY:$version"
    docker push "$REPOSITORY:$version"
fi
