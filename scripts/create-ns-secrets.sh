#!/bin/bash

set -o errexit

#!/bin/bash

# Check for required argument (namespace)
if [ -z "$1" ]; then
  echo "must specify namespace for secret creation"
  exit 1
else
  echo "creating secrets for namespace: $1"
  DEPLOYMENT_NAMESPACE="$1"
fi


if kubectl get namespace "$DEPLOYMENT_NAMESPACE" >/dev/null 2>&1; then
  echo "Namespace $DEPLOYMENT_NAMESPACE exists. Will not attempt to create it."
else
  echo "Namespace $DEPLOYMENT_NAMESPACE does not exist. Creating it now."
  source "$CODESPACE_VSCODE_FOLDER/scripts/create-ns.sh $DEPLOYMENT_NAMESPACE"
fi

# Check for FLOWABLE_LICENSE_KEY
if [ -z "$FLOWABLE_LICENSE_KEY" ]; then
  echo "FLOWABLE_LICENSE_KEY environment variable is not set. Your deployment is likely to fail."
else
  echo "FLOWABLE_LICENSE_KEY is set. Writing its contents to $HOME/.flowable/flowable.license"
  mkdir -p "$HOME/.flowable"
  echo "$FLOWABLE_LICENSE_KEY" > "$HOME/.flowable/flowable.license"
  chmod 600 "$HOME/.flowable/flowable.license"
fi

if [ -z "$2" ]; then
  echo "no license file path specified, using '$HOME/.flowable/flowable.license' by default"
else
  echo "using license file path: $2"
fi

LICENSE_FILE_PATH="${2:-$HOME/.flowable/flowable.license}"

if [ -z "$FLOWABLE_REPO_USER" ]; then
  echo "must have FLOWABLE_REPO_USER env variable set for secret creation"
  exit 1
fi

if [ -z "$FLOWABLE_REPO_PASSWORD" ]; then
  echo "must have FLOWABLE_REPO_PASSWORD env variable set for secret creation"
  exit 1
fi

kubectl create secret docker-registry yourReleaseName-flowable-regcred \
  --docker-server=repo.flowable.com \
  --docker-username="$FLOWABLE_REPO_USER"\
  --docker-password="$FLOWABLE_REPO_PASSWORD"> \
  --namespace $DEPLOYMENT_NAMESPACE

kubectl create secret generic $RELEASE_NAME-flowable-license \
  --from-file=flowable.license="$LICENSE_FILE_PATH" \
  --namespace $DEPLOYMENT_NAMESPACE