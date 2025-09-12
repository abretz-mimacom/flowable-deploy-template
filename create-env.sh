#!/bin/bash

NAMESPACE="${1:-dev}"
RELEASE_NAME="${2:-flowable}"
CLUSTER_NAME="${3:-kind}"

# Get latest scripts
git submodule update --init --recursive --remote --force
chmod a+x scripts/*

# Setup kind cluster
echo "Setting up kind cluster '$CLUSTER_NAME' and deploying Flowable Platform in namespace '$NAMESPACE' with release name '$RELEASE_NAME'"
bash -c "$CODESPACE_VSCODE_FOLDER/scripts/kind-cluster-setup.sh $CLUSTER_NAME" 

# Deploy Flowable Platform
"$CODESPACE_VSCODE_FOLDER/scripts/deploy-flowable-platform.sh" "$NAMESPACE" "$RELEASE_NAME"


k9s -n "$NAMESPACE"