
#!/bin/bash

DISABLE_ARC="${4:-false}"

# Reusable function for cluster setup
setup_cluster() {
	local cluster_name="$1"
	echo "Setting up kind cluster '$cluster_name'"
	export EXTRA_MOUNT_HOST_PATH=docker/keycloak
	"$CODESPACE_VSCODE_FOLDER/scripts/kind-cluster-setup.sh" "$cluster_name" $DISABLE_ARC
	bash -c "echo \"Opening new shell\""


	brew install yq
	bash -c "echo \"Opening new shell after installing yq\""
	echo "re-writing env specific values"
	export AUTH_REDIRECT_URL="https://${CODESPACE_NAME}-443.app.github.dev/work/login/oauth2/code/github"
	export POST_LOGOUT_REDIRECT_URL="https://${CODESPACE_NAME}-443.app.github.dev/work/"
	yq -i '.flowable.work.envVariables."spring.security.oauth2.client.registration.github.redirect-uri" = strenv(AUTH_REDIRECT_URL)' helm/stg/values.yaml
	yq -i '.flowable.work.envVariables."flowable.security.oauth2.post-logout-redirect-url" = strenv(POST_LOGOUT_REDIRECT_URL)' helm/stg/values.yaml

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
		setup_cluster "$3"
		deploy_flowable "$1" "$2"
		# kubectl config set-context --current  --cluster="$3" --namespace="$1"
	done
else
	NAMESPACE="${1:-dev}"
	RELEASE_NAME="${2:-flowable}"
	CLUSTER_NAME="${3:-kind}"
	setup_cluster "$CLUSTER_NAME"
	deploy_flowable "$NAMESPACE" "$RELEASE_NAME"
	# kubectl config set-context --current  --cluster="$CLUSTER_NAME"-kind --namespace="$NAMESPACE"
fi

if [ $1 == "--all" || $1 == "qa" ]; then
	echo "qa-dev Flowable URLS: \n"
	echo "Flowable Work: " $DEV_INGRESS_HOST "work/"
	echo "Flowable Design: " $DEV_INGRESS_HOST "design/"
	echo "Flowable Control: " $DEV_INGRESS_HOST "control/"

	echo "qa-test Flowable URLS: \n"
	echo "Flowable Work: " $TEST_INGRESS_HOST "work/"
	echo "Flowable Control: " $TEST_INGRESS_HOST "control/"
fi

if [ $1 == "--all" || $1 == "prod" ]; then
	echo "prod-stg Flowable URLS: \n"
	echo "Flowable Work: " $STG_INGRESS_HOST "work/"
	echo "Flowable Control: " $STG_INGRESS_HOST "control/"
fi

echo "It is more then likely that you will receive a 503 from these URL's after initial deploy. The pods are still starting."
echo "To see the pods/clusters while they boot, including runtime logs, use the CLI tool K9s. Start by typing the command 'k9s -c --crumbless', then select the cluster you want to interact with to see the pods."

source bash
