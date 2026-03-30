#!/bin/bash

git remote set-url origin "https://github.com/${GITHUB_REPOSITORY}.git"

git submodule sync --recursive && git submodule update --init --recursive

chmod +x scripts/*

## set redirect and weborigin uris for keycloak container
jq --arg uri "https://${CODESPACE_NAME}-443.app.github.dev/login/*" '.clients[] |= if .clientId == "global-sales-demo" then .redirectUris[0] = $uri else . end' docker/keycloak/global-sales-demo-realm.json > /tmp/global-sales-demo-realm.json
mv /tmp/global-sales-demo-realm.json docker/keycloak/global-sales-demo-realm.json	

jq --arg uri "https://${CODESPACE_NAME}-443.app.github.dev/*" '.clients[] |= if .clientId == "global-sales-demo" then .webOrigins[0] = $uri else . end' docker/keycloak/global-sales-demo-realm.json > /tmp/global-sales-demo-realm.json
mv /tmp/global-sales-demo-realm.json docker/keycloak/global-sales-demo-realm.json

export KEYCLOAK_CLIENT_SECRET=some-super-secret-key
jq --arg secret "${KEYCLOAK_CLIENT_SECRET}" '.clients[] |= if .clientId == "global-sales-demo" then .secret = $secret else . end' docker/keycloak/global-sales-demo-realm.json > /tmp/global-sales-demo-realm.json
mv /tmp/global-sales-demo-realm.json docker/keycloak/global-sales-demo-realm.json

jq --arg uri "https://${CODESPACE_NAME}-443.app.github.dev/login" '.clients[] |= if .clientId == "global-sales-demo" then .adminUrl = $uri else . end' docker/keycloak/global-sales-demo-realm.json > /tmp/global-sales-demo-realm.json
mv /tmp/global-sales-demo-realm.json docker/keycloak/global-sales-demo-realm.json
