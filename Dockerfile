ARG UBUNTU_VERSION=20.04

FROM nvidia/cudagl:11.4.2-devel-ubuntu${UBUNTU_VERSION} as base
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},display

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV TORCH_VERSION 1.9.0

RUN apt-get purge -y ".*:i386" && dpkg --remove-architecture i386

RUN apt-get update && apt-get install -y --no-install-recommends \
        mesa-utils \
        build-essential cmake \
        autoconf autogen automake libtool autopoint \
        sudo ssh \
        tzdata \
        libgtk2.0-dev \
        libgtk-3-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        python3-dev \
        python3-numpy \
        python3-pip \
        python3-tk \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libeigen3-dev \
        libdc1394-22-dev \
        pkg-config \
        software-properties-common \
        unzip \
        zip \
        wget \
        git git-lfs \
        vim \
        curl \
        libssl-dev \
        lldb \
        procps \
        lsb-release \
        x11-xserver-utils \
        libmagick++-dev

# cudnn for CUDA 11.4
RUN apt-get update && apt-get install -y --no-install-recommends \
        libcudnn8=8.2.2.26-1+cuda11.4 \
        libcudnn8-dev=8.2.2.26-1+cuda11.4

ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# Enable Vulkan support
RUN add-apt-repository ppa:graphics-drivers/ppa -y && apt-get install -y --no-install-recommends \
    libvulkan1 mesa-vulkan-drivers vulkan-utils glslang-tools

# Set Coordinated Universal Time
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
RUN apt-get update && apt-get install -y tzdata

# Pulseaudio
RUN apt-get install -y --no-install-recommends libpulse-dev pulseaudio-utils
COPY pulseaudio-client.conf /etc/pulse/client.conf

# GStreamer
RUN apt-get update && apt-get install -y \
    gtk-doc-tools libglib2.0-dev bison flex gettext graphviz yasm \
    liborc-0.4-0 liborc-0.4-dev libvorbis-dev libcdparanoia-dev \
    libcdparanoia0 cdparanoia libvisual-0.4-0 libvisual-0.4-dev libvisual-0.4-plugins libvisual-projectm \
    vorbis-tools vorbisgain libopus-dev libopus-doc libopus0 libopusfile-dev libopusfile0 \
    libtheora-bin libtheora-dev libtheora-doc libvpx-dev libvpx-doc \
    libflac++-dev libavc1394-dev \
    libraw1394-dev libraw1394-tools libraw1394-doc libraw1394-tools \
    libtag1-dev libtagc0-dev libwavpack-dev wavpack \
    libfontconfig1-dev libfreetype6-dev \
    libxv-dev libx11-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libx11-xcb-dev libxcb-glx0-dev \
    libasound2-dev libavcodec-dev libavformat-dev libswscale-dev \
    libwebrtc-audio-processing-dev \
    libsrtp2-dev
RUN apt-get update && apt-get install -y \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav libgstrtspserver-1.0-dev

RUN apt-get upgrade -y && apt-get autoremove

# LibTorch TORCH_VERSION
WORKDIR /opt
RUN wget -O libtorch_${TORCH_VERSION}.zip https://download.pytorch.org/libtorch/cu111/libtorch-cxx11-abi-shared-with-deps-${TORCH_VERSION}%2Bcu111.zip && \
    unzip libtorch_${TORCH_VERSION}.zip && \
    rm libtorch_${TORCH_VERSION}.zip
ENV LIBTORCH /opt/libtorch

# Fix missing libnvrtc-builtins.so.11.1
RUN ln -s /usr/local/cuda/targets/x86_64-linux/lib/libnvrtc-builtins.so.11.4 /usr/local/cuda/targets/x86_64-linux/lib/libnvrtc-builtins.so.11.1

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
    
ARG USERNAME=sim
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && mkdir -p /home/$USERNAME/.vscode-server /home/$USERNAME/.vscode-server-insiders \
    && chown ${USER_UID}:${USER_GID} /home/$USERNAME/.vscode-server* \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && usermod -a -G audio,video $USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME
ENV HOME /home/$USERNAME
WORKDIR $HOME

# Latest stable Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
ENV PATH=$HOME/.cargo/bin:$PATH
RUN rustup toolchain install 1.55.0
RUN rustup component add rls rust-analysis rust-src rustfmt clippy
RUN cargo install fd-find ripgrep

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=