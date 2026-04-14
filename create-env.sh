
#!/bin/bash

NAMESPACE="${1:-dev}"
RELEASE_NAME="${2:-flowable}"
CLUSTER_NAME="${3:-kind}"
DISABLE_ARC="${4:-false}"

source ~/.bashrc
/bin/bash -c "echo \"Updating values for this environment\""
yq -i '.flowable.work.envVariables."spring.security.oauth2.client.registration.github.redirect-uri" = strenv(AUTH_REDIRECT_URL)' helm/stg/values.yaml
yq -i '.flowable.work.envVariables."flowable.security.oauth2.post-logout-redirect-url" = strenv(POST_LOGOUT_REDIRECT_URL)' helm/stg/values.yaml

yq -i '.flowable.ingress.host = strenv(DEV_INGRESS_HOST)' helm/dev/values.yaml
yq -i '.flowable.ingress.host = strenv(TEST_INGRESS_HOST)' helm/test/values.yaml
yq -i '.flowable.ingress.host = strenv(STG_INGRESS_HOST)' helm/stg/values.yaml

# Reusable function for cluster setup
setup_cluster() {
	local cluster_name="$1"
	echo "Setting up kind cluster '$cluster_name'"
	export EXTRA_MOUNT_HOST_PATH=docker/keycloak
	"$CODESPACE_VSCODE_FOLDER/scripts/kind-cluster-setup.sh" "$cluster_name" $DISABLE_ARC

}

# Reusable function for deployment
deploy_flowable() {
	local namespace="$1"
	local release_name="$2"
	echo "Deploying Flowable Platform in namespace '$namespace' with release name '$release_name'"
	"$CODESPACE_VSCODE_FOLDER/scripts/deploy-flowable-platform.sh" "$namespace" "$release_name"
}


# Check for --all flag
if [[ "$1" == "--all" ]]; then
	# Array of configurations: (namespace release_name cluster_name)
	configs=(
		"dev flowable qa"
        "test flowable qa"
		"stg flowable prod"
	)
	for config in "${configs[@]}"; do
		set -- $config
		setup_cluster "$3";
		echo "Setting kubectl context to --cluster=\"kind-$3\" --namespace=\"$1\""
		kubectl config use-context "kind-$3" --namespace="$1"
		deploy_flowable "$1" "$2"
		source ~/.bashrc
	done
else

	setup_cluster "$3"
	echo "Setting kubectl context to --cluster=\"kind-${CLUSTER_NAME}\" --namespace=\"${NAMESPACE}\""
	kubectl config use-context "kind-${CLUSTER_NAME}" --namespace="${NAMESPACE}"
	deploy_flowable "$NAMESPACE" "$RELEASE_NAME"
fi

if [[ $1 == "--all" || $1 == "qa" ]]; then
	echo "qa-dev Flowable URLS: \n"
	echo "Flowable Work: " $DEV_INGRESS_HOST "work/"
	echo "Flowable Design: " $DEV_INGRESS_HOST "design/"
	echo "Flowable Control: " $DEV_INGRESS_HOST "control/"

	echo "qa-test Flowable URLS: \n"
	echo "Flowable Work: " $TEST_INGRESS_HOST "work/"
	echo "Flowable Control: " $TEST_INGRESS_HOST "control/"
fi

if [[ $1 == "--all" || $1 == "prod" ]]; then
	echo "prod-stg Flowable URLS: \n"
	echo "Flowable Work: " $STG_INGRESS_HOST "work/"
	echo "Flowable Control: " $STG_INGRESS_HOST "control/"
fi
