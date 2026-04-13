#!/bin/bash

git remote add origin "https://github.com/${GITHUB_REPOSITORY}.git"
git fetch
git checkout dev

git submodule sync --recursive && git submodule update --init --recursive && git submodule update --remote
chmod +x scripts/*

if ! command -v kind >/dev/null 2>&1; then
  echo "kind not found, installing..."
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found, installing..."
    NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  brew install kind derailed/k9s/k9s yq
  /bin/bash -c "echo installed kind and k9s. Opening new bash shell to continue execution from"
fi

echo "re-writing env specific values"
echo "export DEV_INGRESS_HOST=\"https://${CODESPACE_NAME}-80.app.github.dev/dev\"" >> ~/.bashrc
echo "export TEST_INGRESS_HOST=\"https://${CODESPACE_NAME}-80.app.github.dev/test\"" >> ~/.bashrc
echo "export STG_INGRESS_HOST=\"https://${CODESPACE_NAME}-443.app.github.dev/stg\"" >> ~/.bashrc
echo "export AUTH_REDIRECT_URL=\"${STG_INGRESS_HOST}/work/login/oauth2/code/github\"" >> ~/.bashrc
echo "export POST_LOGOUT_REDIRECT_URL=\"${STG_INGRESS_HOST}/work/#/\"" >> ~/.bashrc

DEV_INGRESS_HOST="https://${CODESPACE_NAME}-80.app.github.dev/dev"
TEST_INGRESS_HOST="https://${CODESPACE_NAME}-80.app.github.dev/test"
STG_INGRESS_HOST="https://${CODESPACE_NAME}-443.app.github.dev/stg"
AUTH_REDIRECT_URL="${STG_INGRESS_HOST}/work/login/oauth2/code/github"
POST_LOGOUT_REDIRECT_URL="${STG_INGRESS_HOST}/work/#/"

yq -i '.flowable.work.envVariables."spring.security.oauth2.client.registration.github.redirect-uri" = strenv(AUTH_REDIRECT_URL)' helm/stg/values.yaml
yq -i '.flowable.work.envVariables."flowable.security.oauth2.post-logout-redirect-url" = strenv(POST_LOGOUT_REDIRECT_URL)' helm/stg/values.yaml

yq -i '.flowable.ingress.host = strenv(DEV_INGRESS_HOST)' helm/dev/values.yaml
yq -i '.flowable.ingress.host = strenv(TEST_INGRESS_HOST)' helm/test/values.yaml
yq -i '.flowable.ingress.host = strenv(STG_INGRESS_HOST)' helm/stg/values.yaml
