#!/bin/bash

NAMESPACE="${1:-dev}"
RELEASE_NAME="${2:-flowable}"

git submodule update --init --recursive --remote --force
chmod a+x scripts/*

bash -c "$CODESPACE_VSCODE_FOLDER/scripts/kind-cluster-setup.sh" "$NAMESPACE"

"$CODESPACE_VSCODE_FOLDER/scripts/deploy-flowable-platform.sh" "$NAMESPACE" "$RELEASE_NAME"

k9s -n "$NAMESPACE"