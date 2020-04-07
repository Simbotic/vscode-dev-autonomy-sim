#!/usr/bin/env bash

docker run --rm -ti --name simbotic-container --gpus=all \
    -e DISPLAY=$DISPLAY \
    -e SSH_AUTH_SOCK=/ssh-agent \
    -e PULSE_SERVER=unix:/tmp/pulseaudio.socket \
    -e PULSE_COOKIE=/tmp/pulseaudio.cookie \
    -v /tmp/pulseaudio.socket:/tmp/pulseaudio.socket \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $SSH_AUTH_SOCK:/ssh-agent \
    --network=host \
    --cap-add=SYS_PTRACE \
    simbotic-container-base
