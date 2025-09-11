#!/bin/bash

set -o errexit

#!/bin/bash

if [ -z "$1" ]; then
  echo "must specify namespace for secret creation"
  exit 1
else
  echo "using namespace: $1"
  DEPLOYMENT_NAMESPACE=$1
fi

kubectl create secret docker-registry yourReleaseName-flowable-regcred \
  --docker-server=repo.flowable.com \
  --docker-username="$FLOWABLE_REPO_USER"\
  --docker-password="$FLOWABLE_REPO_PASSWORD"> \
  --namespace $DEPLOYMENT_NAMESPACE

kubectl create secret generic yourReleaseName-flowable-license --from-file=flowable.license=/your/local/licensefile/location/flowable.license --namespace $DEPLOYMENT_NAMESPACE