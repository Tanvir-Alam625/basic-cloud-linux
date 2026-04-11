#!/bin/bash
# install-common-tools.sh
# Installs commonly used DevOps tools on Ubuntu 22.04.
# Run this on a fresh EC2 instance to set up your environment.
#
# Usage: bash install-common-tools.sh

set -e

echo "Updating package index..."
sudo apt update -q

echo "Upgrading installed packages..."
sudo apt upgrade -y -q

# NOTE: bash line continuation (\) must be the very last character on the line.
# Inline comments after \ break apt install — all comments are on separate lines.
echo "Installing core tools..."
# Packages:
#   curl      — HTTP requests and file downloads
#   wget      — File downloads
#   git       — Version control
#   unzip     — Extract .zip files
#   htop      — Interactive process monitor
#   tree      — Directory tree viewer
#   net-tools — netstat and legacy network tools
#   jq        — Parse and format JSON (very useful with AWS CLI output)
#   vim       — Text editor
#   tmux      — Terminal multiplexer (keeps sessions alive after SSH disconnect)
sudo apt install -y \
  curl \
  wget \
  git \
  unzip \
  htop \
  tree \
  net-tools \
  jq \
  vim \
  tmux

echo ""
echo "Installed versions:"
echo "  curl:  $(curl --version | head -1)"
echo "  git:   $(git --version)"
echo "  jq:    $(jq --version)"
echo "  tmux:  $(tmux -V)"

echo ""
echo "All tools installed successfully."
