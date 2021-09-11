#title           :Dockerfile
#description     :This file contains instructions for building a docker image.
#                 For example, this file can be executed by running
#                 "docker build -t image_name:latest ."
#author          :Austin Owens
#date            :9/5/2021
#version         :0.1
#common_usage	 :docker build -t <image_name>[:<image_tag>] ./
#notes           :ARG arguments used throughout dockerfile can be overwritten by
#                 passing --build-arg <arg>=<val> to the "docker build" cmd
#                 where <arg> is the argument name and <val> is the value
#docker_version  :20.10.8
#==============================================================================

# Download latest base image from ubuntu
FROM ubuntu:latest

# LABEL about the custom image
LABEL version="0.1"
LABEL description="This is custom Docker Image for a Cardano sandbox."

# Starting work directory
WORKDIR /root

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update and upgrade Ubuntu software repository and install various packages
# from ubuntu repository
RUN apt-get update && apt upgrade -y

# Install various system-level packages from ubuntu repository
RUN apt-get install -y automake build-essential pkg-config make g++ tmux git \
 && apt-get install -y jq wget libtool autoconf curl

# Install various lib packages from ubuntu repository
RUN apt-get install -y libffi-dev libgmp-dev libssl-dev libtinfo-dev \
 && apt-get install -y libsystemd-dev zlib1g-dev libncursesw5 

# Install GHC and Cabal
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org -sSf | sh -s -- -y

# Add ghcup bin to PATH
ENV PATH="/root/.ghcup/bin:$PATH"

# Install specific ghc version
RUN ghcup install ghc 8.10.4
RUN ghcup set ghc 8.10.4

# Make a Cardano source code directory
RUN mkdir -p ~/cardano-src

# Download and install libsodium
RUN cd ~/cardano-src && git clone https://github.com/input-output-hk/libsodium \
    && cd libsodium && git checkout 66f017f1 && ./autogen.sh && ./configure \
    && make && make install

# Add the following environment variables so the compiler can be aware 
# libsodium is installed
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

# Download cardano-node
RUN cd ~/cardano-src && git clone https://github.com/input-output-hk/cardano-node.git \
    && cd cardano-node && git fetch --all --recurse-submodules --tags \
    && git checkout tags/1.29.0

# Configure cardano-node
RUN cd ~/cardano-src/cardano-node && cabal configure --with-compiler=ghc-8.10.4 \
    && echo "package cardano-crypto-praos" >>  cabal.project.local \
    && echo "  flags: -external-libsodium-vrf" >>  cabal.project.local

# Build  cardano-node
RUN cd ~/cardano-src/cardano-node && cabal build all

# Install cardano-node
RUN mkdir -p ~/.local/bin && cd ~/cardano-src/cardano-node \
    && cp -p "$(./scripts/bin-path.sh cardano-node)" ~/.local/bin/ \
    && cp -p "$(./scripts/bin-path.sh cardano-cli)" ~/.local/bin/

# Add ~/.local/bin to PATH so system can find cardano-node and cardano-cli
ENV PATH="~/.local/bin:$PATH"

# Install software packages from ubuntu repository for general dev
RUN apt-get update && apt-get install -y net-tools tree htop vim tini

# Use bash for remaining of file (default is sh)
SHELL ["/bin/bash", "-c"]

# Create mount location for user in case they want to share files across host
# and container
VOLUME /mnt/shared

# Coping entrypoint script into /usr/local/bin/
COPY ./docker-entrypoint.sh /usr/local/bin

# Setting entrypoint script so the container can prepare the environment before
# control is passed to the user. Also using tini here to serve as PID 1 so that
# it can handle any zombie process clean-up and/or the passing of kill signals 
# to other processes
ENTRYPOINT ["/usr/bin/tini", "-v", "--", "/usr/local/bin/docker-entrypoint.sh"]

# Adding environment variables for custom cardano scripts and cardano-cli
ENV CARDANO_CONFIG_PATH="/root/cardano-data/configs"
ENV CARDANO_DB_PATH="/root/cardano-data/db"
ENV CARDANO_NODE_SOCKET_PATH="/root/cardano-data/db/node.socket"

# Default cmd when starting the container if not overwritten by user.
CMD /bin/bash
