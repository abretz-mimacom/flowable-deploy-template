#!/bin/bash

NAMESPACE="${1:-dev}"
RELEASE_NAME="${2:-flowable}"

git submodule update --recursive --remote --force
chmod a+x scripts/*

source "$CODESPACE_VSCODE_FOLDER/scripts/kind-cluster-setup.sh" "$NAMESPACE"

source "$CODESPACE_VSCODE_FOLDER/scripts/deploy-flowable-platform.sh" "$NAMESPACE" "$RELEASE_NAME"