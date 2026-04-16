
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

docker-compose -f docker/docker-compose.yml up -d
# Reusable function for cluster setup
setup_cluster() {
	local cluster_name="$1"
	echo "Setting up kind cluster '$cluster_name'"
	export EXTRA_MOUNT_HOST_PATH=docker
	"$CODESPACE_VSCODE_FOLDER/scripts/kind-cluster-setup.sh" "$cluster_name" $DISABLE_ARC
	source ~/.bashrc
	if [ ! -f "/home/codespace/.ssh/id_rsa" ]; then
		mkdir -p /home/codespace/.ssh
		ssh-keygen -t rsa -b 4096 -f /home/codespace/.ssh/id_rsa -P ""
		echo "$ARC_TOKEN" | gh auth login -p https --with-token
		gh ssh-key add /home/codespace/.ssh/id_rsa.pub --title "${CODESPACE_NAME}" --type authentication
	fi

	if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "docker-flowable-db-1")" = 'null' ]; then
		echo "Connecting kind network to db container"
		docker network connect "kind" "docker-flowable-db-1"
	fi

	if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "docker-flowable-index-1")" = 'null' ]; then
		echo "Connecting kind network to index container"
		docker network connect "kind" "docker-flowable-index-1"
	fi

}

# Reusable function for deployment
deploy_flowable() {
	local namespace="$1"
	local release_name="$2"
	echo "Deploying Flowable Platform in namespace '$namespace' with release name '$release_name'"
	"$CODESPACE_VSCODE_FOLDER/scripts/deploy-flowable-platform.sh" "$namespace" "$release_name"
	if [ ! -f "docker/.ssh/id_rsa" ]; then
		sudo mkdir -p docker/.ssh
		echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=" >> docker/.ssh/known_hosts
		sudo cp /home/codespace/.ssh/id_rsa docker/.ssh/
		sudo cp /home/codespace/.ssh/id_rsa.pub docker/.ssh/
		sudo chmod +rw docker/.ssh
		sudo chown 100:100 docker/.ssh/id_rsa docker/.ssh/id_rsa.pub docker/.ssh/known_hosts
	fi
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
