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

buildah login --password $DOCKER_PASSWORD --username $DOCKER_USERNAME $DOCKER_REGISTRY

# push e.g. osism/openstackclient:wallaby
buildah tag "$REPOSITORY:$REVISION" "$REPOSITORY:$VERSION"
buildah push "$REPOSITORY:$VERSION"

# push e.g. osism/openstackclient:5.5.0
version=$(podman run --rm "$REPOSITORY:$VERSION" openstack --version | awk '{ print $2 }')

if skopeo inspect --creds "${DOCKER_USERNAME}:${DOCKER_PASSWORD}" "docker://${REPOSITORY}:${version}" > /dev/null; then
    echo "The image ${REPOSITORY}:${version} already exists."
else
    buildah tag "$REPOSITORY:$REVISION" "$REPOSITORY:$version"
    buildah push "$REPOSITORY:$version"
fi
