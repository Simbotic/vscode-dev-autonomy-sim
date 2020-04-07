# Simbotic Container
Docker (and VSCode DevContainer) for running Simbotic family of computer vision and simulation tools.

## Supports
- SimboticEngine (UnrealEngine 4.0) and plugins
- SimboticTorch (LibTorch GPU)

## Contains
- Rust 1.42.0
- GStreamer 1.14.5
- LibTorch 1.4.0
- CUDA 10.1
- cuDNN 7.6.5
- OpenCV 4.1.1

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
