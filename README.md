# Simbotic Container
Docker (and VSCode DevContainer) for running Simbotic family of computer vision and simulation tools.

![](images/test.png)

## Supports
- SimboticEngine (UnrealEngine 4.0) and plugins
- SimboticTorch (LibTorch GPU)

## Features
- Rust 1.42.0
- GStreamer 1.16.2 (with WebRTC and Data Channels)
- LibTorch 1.4.0 - GPU
- CUDA 10.1
- cuDNN 7.6.5
- nvidia/cudagl:10.1-devel-ubuntu18.04
- Inherits UID/GID from host user
- ssh keys added to container agent
- VSCode Remote Containers

![](images/features.png)

## Pre-requisites

### Audio setup
On host, create pulseaudio socket:

```
pactl load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket
```
Now creates a file (`/tmp/pulseaudio.client.conf`) that contains the following:

```
default-server = unix:/tmp/pulseaudio.socket
# Prevent a server running in the container
autospawn = no
daemon-binary = /bin/true
# Prevent the use of shared memory
enable-shm = false
```

### NVidia setup

Setup NVidia docker:
https://github.com/NVIDIA/nvidia-docker

## Setup Docker container
```
./docker_build.sh
./docker_run.sh
```

## Or Setup for VSCode Remote Containers

Move to the root directory of your project and run:
```
git submodule add git@github.com:VertexStudio/SimboticContainer.git .devcontainer
```

VSCode:
- Install the VSCode extension [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Press <kbd>F1</kbd> to bring up the Command Palette and type in *remote-containers* for a full list of commands
- Run the `Remote-Containers: Reopen in Container` command or run `Remote-Containers: Open Folder in Container...` command and select the local folder

**Note:** If you don't want this as a Git Submodule, you may also choose to download this repository as a **zip**, extract its content, and paste it in a `.devcontainer` directory at the root of your project.

![](images/devcontainer.png)

## Test using SimboticTorch
https://github.com/Simbotic/SimboticTorch


## Run Simbotic Engine

You must need to download, build and set `$SIMBOTIC_ENGINE` env variable to run within the container. Please refer to [Simbotic Repo](https://github.com/Simbotic/SimboticEngine) in order to set all of this.

After all the variables are in place, we need to run the build script:

```
./docker_build.sh
```
This will create the docker image according the Dockerfile. Then, 

```
./docker_run.sh
```