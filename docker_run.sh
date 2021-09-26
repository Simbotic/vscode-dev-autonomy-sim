#!/usr/bin/env bash

docker run --rm -ti \
    --gpus=all \
    --cap-add=SYS_PTRACE \
    --security-opt seccomp=unconfined \
    --network=host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e PULSE_SERVER=unix:/tmp/pulseaudio.socket \
    -e PULSE_COOKIE=/tmp/pulseaudio.cookie \
    -v /tmp/pulseaudio.socket:/tmp/pulseaudio.socket \
    -e SSH_AUTH_SOCK=/ssh-agent \
    -v $SSH_AUTH_SOCK:/ssh-agent \
    -v "$(pwd)":/sim \
    simbotic-container-base
