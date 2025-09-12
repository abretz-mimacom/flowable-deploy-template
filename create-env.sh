#!/bin/bash

NAMESPACE="${1:-dev}"
RELEASE_NAME="${2:-flowable}"

git submodule update --init --recursive --remote --force
chmod a+x scripts/*

# Check if kind is installed, install with brew if not
if ! command -v kind >/dev/null 2>&1; then
  echo "kind not found, installing..."
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found, installing..."
    NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  brew install kind derailed/k9s/k9s
fi

bash -c "$CODESPACE_VSCODE_FOLDER/scripts/kind-cluster-setup.sh" "$NAMESPACE"

"$CODESPACE_VSCODE_FOLDER/scripts/deploy-flowable-platform.sh" "$NAMESPACE" "$RELEASE_NAME"