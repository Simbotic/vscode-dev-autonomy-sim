ARG UBUNTU_VERSION=18.04

FROM nvidia/cudagl:10.1-devel-ubuntu${UBUNTU_VERSION} as base
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},display

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

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
        python-dev \
        python-numpy \
        python3-dev \
        python3-numpy \
        python-pip \
        python3-pip \
        python-tk \
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

# CUDA 10.1
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-command-line-tools-10-1 \
        cuda-cufft-10-1 \
        cuda-curand-10-1 \
        cuda-cusolver-10-1 \
        cuda-cusparse-10-1 \
        libcudnn7=7.6.5.32-1+cuda10.1 \
        libcudnn7-dev=7.6.5.32-1+cuda10.1

ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# Set Coordinated Universal Time
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
RUN apt-get update && apt-get install -y tzdata

# Pulseaudio
RUN apt-get install -y --no-install-recommends libpulse-dev pulseaudio-utils
COPY pulseaudio-client.conf /etc/pulse/client.conf

# GStreamer 1.16
RUN apt-get update && apt-get install \
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

RUN apt-get upgrade -y && apt-get autoremove

COPY nvidia-video/include/* /usr/local/cuda/include/

RUN mkdir /opt/src
WORKDIR /opt/src
RUN git clone -b 0.1.16 --single-branch https://gitlab.freedesktop.org/libnice/libnice.git
RUN git clone -b master --single-branch https://github.com/sctplab/usrsctp.git
RUN git clone -b 1.16 --single-branch https://gitlab.freedesktop.org/gstreamer/gst-libav.git
RUN git clone -b 1.16 --single-branch https://gitlab.freedesktop.org/gstreamer/gstreamer.git
RUN git clone -b 1.16 --single-branch https://gitlab.freedesktop.org/gstreamer/gst-plugins-base.git
RUN git clone -b 1.16 --single-branch https://gitlab.freedesktop.org/gstreamer/gst-plugins-good.git
RUN git clone -b 1.16 --single-branch https://gitlab.freedesktop.org/gstreamer/gst-plugins-bad.git
RUN git clone -b 1.16 --single-branch https://gitlab.freedesktop.org/gstreamer/gst-plugins-ugly.git
COPY build_gstreamer.sh build_gstreamer.sh
RUN chmod +x build_gstreamer.sh
RUN ./build_gstreamer.sh

# LibTorch 1.4.0
WORKDIR /opt
RUN wget -O libtorch_1.4.0.zip https://download.pytorch.org/libtorch/cu101/libtorch-cxx11-abi-shared-with-deps-1.4.0.zip && \
    unzip libtorch_1.4.0.zip && \
    rm libtorch_1.4.0.zip
ENV LIBTORCH /opt/libtorch

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
RUN rustup toolchain install 1.42.0
RUN rustup component add rls rust-analysis rust-src rustfmt clippy
RUN cargo install fd-find ripgrep

# RUN pip install --user setuptools wheel image 
# RUN pip install --user torch torchvision

# RUN pip3 install --user setuptools wheel image
# RUN pip3 install --user torch torchvision

# RUN pip install --user matplotlib
# RUN pip3 install --user matplotlib

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=