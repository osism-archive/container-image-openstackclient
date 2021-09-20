#!/usr/bin/env bash
set -x

# Available environment variables
#
# BUILD_OPTS
# DOCKER_REGISTRY
# PYTHON_VERSION
# REPOSITORY
# VERSION

# Set default values

BUILD_OPTS=${BUILD_OPTS:-}
CREATED=$(date --rfc-3339=ns)
DOCKER_REGISTRY=${DOCKER_REGISTRY:-quay.io}
PYTHON_VERSION=${PYTHON_VERSION:-3.7}
REVISION=$(git rev-parse HEAD)
VERSION=${VERSION:-latest}

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

mkdir -p "$HOME/.config/containers"
echo "unqualified-search-registries = ['docker.io']" > "$HOME/.config/containers/registries.conf"

#echo -e '[storage.options]\nmount_program = "/usr/bin/fuse-overlayfs"' > ~/.config/containers/storage.conf
echo -e '[storage.options]\nmount_program = "/usr/bin/fuse-overlayfs"\n[storage]\ndriver = "overla"' > ~/.config/containers/storage.conf

buildah build-using-dockerfile \
    --isolation chroot \
    --storage-driver=vfs \
    --build-arg "PYTHON_VERSION=$PYTHON_VERSION" \
    --build-arg "VERSION=$VERSION" \
    --tag "$REPOSITORY:$REVISION" \
    --label "org.opencontainers.image.created=$CREATED" \
    --label "org.opencontainers.image.revision=$REVISION" \
    --label "org.opencontainers.image.version=$VERSION" \
    $BUILD_OPTS .
