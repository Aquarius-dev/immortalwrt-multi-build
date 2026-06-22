#!/bin/bash
# setup-build-env.sh - Setup ImmortalWrt build environment
set -e

echo "🔧 Setting up build environment..."

# Install dependencies
sudo apt-get update -qq
sudo apt-get install -y build-essential ccache clang flex bison g++ gawk \
  gcc-multilib g++-multilib gettext git git-lfs libncurses-dev libssl-dev \
  libelf-dev python3 python3-pip python3-setuptools python3-dev rsync unzip \
  zlib1g-dev file wget qemu-utils upx-ucl autoconf automake libtool \
  libtool-bin libtool-doc curl time > /dev/null 2>&1

echo "✅ Dependencies installed"

# Setup locale
sudo locale-gen en_US.UTF-8 > /dev/null 2>&1

# Install Python packages
sudo pip3 install -q pyelftools

echo "✅ Python packages installed"
