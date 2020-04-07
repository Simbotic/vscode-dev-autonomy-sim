#!/usr/bin/env bash

docker build \
    --build-arg USER_UID=$(id -u ${USER}) \
    --build-arg USER_GID=$(id -g ${USER}) \
    -f Dockerfile \
    -t simbotic-container-base .