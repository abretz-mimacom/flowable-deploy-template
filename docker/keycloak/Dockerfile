FROM keycloak/keycloak:20.0.0
COPY global-sales-demo-realm.json /tmp/oauth2-stack-realm-original.json
RUN mkdir -p /opt/keycloak/data/import
COPY global-sales-demo-realm.json /opt/keycloak/data/import/realms.json
# COPY customize-realm.sh /tmp/customize-realm.sh
# ENTRYPOINT [ "/tmp/customize-realm.sh" ]