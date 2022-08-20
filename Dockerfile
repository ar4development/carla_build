FROM nvidia/vulkan:1.1.121

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
RUN apt update && apt install -y locales && locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && export LANG=en_US.UTF-8
RUN apt install -y --no-install-recommends tzdata && apt install -y keyboard-configuration

# Install dependencies
RUN apt update && apt install -y wget software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add - && \
    apt-add-repository "deb http://apt.llvm.org/$(lsb_release -c --short)/ llvm-toolchain-$(lsb_release -c --short)-8 main"

# Additional dependencies for Ubuntu 18.04
RUN apt update && apt install -y libllvm8 libclang-common-8-dev build-essential clang-8 lld-8 g++-7 \
    cmake ninja-build libvulkan1 python python-pip python-dev python3-dev \
    python3-pip libpng-dev libtiff5-dev libjpeg-dev tzdata sed curl unzip \
    autoconf libtool rsync libxml2-dev git && \
    pip2 install setuptools && pip3 install -Iv setuptools==47.3.1


# Additional dependencies for previous Ubuntu versions
RUN apt install -y build-essential clang-8 lld-8 g++-7 cmake ninja-build libvulkan1 \
    python python-pip python-dev python3-dev python3-pip libpng-dev libtiff5-dev \
    libjpeg-dev tzdata sed curl unzip autoconf libtool rsync libxml2-dev git

RUN pip2 install setuptools && \
    pip3 install -Iv setuptools==47.3.1 && \
    pip2 install distro && \
    pip3 install distro

# Change default clang version
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-8/bin/clang++ 180 && \
    update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-8/bin/clang 180

# Install SDL
RUN apt install -y libsdl2-dev libsdl2-2.0-0 libjpeg-dev libwebp-dev \
    libtiff5-dev libsdl2-image-dev libsdl2-image-2.0-0 \
    libmikmod-dev libfishsound1-dev libsmpeg-dev liboggz2-dev libflac-dev libfluidsynth-dev libsdl2-mixer-dev libsdl2-mixer-2.0-0 \
    libfreetype6-dev libsdl2-ttf-dev libsdl2-ttf-2.0-0

# Create dedicated user. In some reason GUI does not work under root.
RUN useradd -ms /bin/bash mavs
USER mavs

WORKDIR /home/mavs

# Set up github ssh access
RUN mkdir .ssh && ssh-keyscan -H github.com  >> .ssh/known_hosts
COPY --chown=mavs:mavs carla_keys /home/mavs

# Download Unreal Engine 4.24
RUN GIT_SSH_COMMAND="ssh -i /home/mavs/carla_keys" git clone --depth 1 -b carla ssh://git@github.com/CarlaUnreal/UnrealEngine.git UnrealEngine_4.26

WORKDIR /home/mavs/UnrealEngine_4.26

# Build Unreal Engine
RUN ./Setup.sh && ./GenerateProjectFiles.sh && make

# Clone carla project
WORKDIR /home/mavs
RUN git clone https://github.com/carla-simulator/carla
RUN cd carla && git checkout 0.9.13

WORKDIR /home/mavs/carla
RUN ./Update.sh
RUN echo "export UE4_ROOT=/home/mavs/UnrealEngine_4.26" > /home/mavs/.bashrc
RUN UE4_ROOT=/home/mavs/UnrealEngine_4.26 make PythonAPI

# Now you may enter the container and call 'make launch'
