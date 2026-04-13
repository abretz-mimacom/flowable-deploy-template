#!/bin/bash

git remote add origin "https://github.com/${GITHUB_REPOSITORY}.git"
git fetch
git checkout dev

git submodule sync --recursive && git submodule update --init --recursive && git submodule update --remote
chmod +x scripts/*

if ! command -v kind >/dev/null 2>&1; then
  echo "kind not found, installing..."
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found, installing..."
    NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  brew install kind derailed/k9s/k9s yq
  /bin/bash -c "echo installed kind and k9s. Opening new bash shell to continue execution from"
fi