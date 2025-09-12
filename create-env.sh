#!/bin/bash

NAMESPACE="${1:-dev}"
RELEASE_NAME="${2:-flowable}"

# Get latest scripts
git submodule update --init --recursive --remote --force
chmod a+x scripts/*

# Setup kind cluster
bash -c "$CODESPACE_VSCODE_FOLDER/scripts/kind-cluster-setup.sh" "$NAMESPACE"

# Deploy Flowable Platform
"$CODESPACE_VSCODE_FOLDER/scripts/deploy-flowable-platform.sh" "$NAMESPACE" "$RELEASE_NAME"


k9s -n "$NAMESPACE"