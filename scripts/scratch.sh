#!/usr/bin/env bash

sudo modprobe fuse

podman pull docker://quay.io/buildah/stable:latest
podman run --privileged stable buildah version
