# Simbotic Container
Docker (and VSCode DevContainer) for running computer vision and simulation tools.

![](images/test.png)

## Supports
- SimboticEngine (UnrealEngine 4.0) and plugins
- SimboticTorch (LibTorch GPU)

## Features
- Stable Rust 1.55.0
- GStreamer 1.16.2 (with WebRTC and Data Channels)
- LibTorch 1.9.0 - GPU
- CUDA 11.4
- cuDNN 8.2.2
- nvidia/cudagl:11.4.2-devel-ubuntu20.04
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

### NVidia Docker 2 setup

Setup NVidia docker:
https://github.com/NVIDIA/nvidia-docker

Install:
```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

Test nvidia-docker installation:
```
docker run --rm --gpus all nvidia/cudagl:11.4.2-devel-ubuntu20.04 nvidia-smi
```

## Setup Docker container
```
./docker_build.sh
./docker_run.sh
```

## Or Setup for VSCode Remote Containers

Move to the root directory of your project and run:
```
git submodule add git@github.com:Simbotic/SimboticContainer.git .devcontainer
```

VSCode:
- Install the VSCode extension [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Press <kbd>F1</kbd> to bring up the Command Palette and type in *remote-containers* for a full list of commands
- Run the `Remote-Containers: Reopen in Container` command or run `Remote-Containers: Open Folder in Container...` command and select the local folder

**Note:** If you don't want this as a Git Submodule, you may also choose to download this repository as a **zip**, extract its content, and paste it in a `.devcontainer` directory at the root of your project.

![](images/devcontainer.png)

## Test using SimboticTorch
https://github.com/Simbotic/SimboticTorch
