FROM keycloak/keycloak:20.0.0
COPY global-sales-demo-realm.json /tmp/oauth2-stack-realm-original.json
COPY customize-realm.sh /tmp/customize-realm.sh
ENTRYPOINT [ "/tmp/customize-realm.sh" ]