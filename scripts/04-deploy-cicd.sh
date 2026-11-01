#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00-configurar-ambiente.sh"
require_secret MYSQL_USER MYSQL_PASSWORD ARTIFACT_DIR IMAGE_TAG
[[ "$IMAGE_TAG" =~ ^[0-9]+$ ]] || { echo 'Tag deve ser BuildId numerico'; exit 1; }
test -s "$ARTIFACT_DIR/app.jar"
cp docker/app/Dockerfile.cicd "$ARTIFACT_DIR/Dockerfile"
az acr build --registry "$ACR_NAME" --image "$APP_IMAGE:$IMAGE_TAG" --file "$ARTIFACT_DIR/Dockerfile" "$ARTIFACT_DIR" --no-logs --output none
ACR_USERNAME=$(az acr credential show -n "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show -n "$ACR_NAME" --query 'passwords[0].value' -o tsv)
DB_FQDN=$(az container show -g "$RESOURCE_GROUP" -n "$DB_ACI" --query ipAddress.fqdn -o tsv)
az container create -g "$RESOURCE_GROUP" -n "$APP_ACI" \
 --image "$ACR_NAME.azurecr.io/$APP_IMAGE:$IMAGE_TAG" --cpu 1 --memory 1.5 \
 --os-type Linux --dns-name-label "$APP_ACI" --ports 8080 \
 --registry-login-server "$ACR_NAME.azurecr.io" \
 --registry-username "$ACR_USERNAME" --registry-password "$ACR_PASSWORD" \
 --environment-variables SPRING_DATASOURCE_URL="jdbc:mysql://${DB_FQDN}:3306/zelo?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" \
 --secure-environment-variables SPRING_DATASOURCE_USERNAME="$MYSQL_USER" SPRING_DATASOURCE_PASSWORD="$MYSQL_PASSWORD" \
 --restart-policy Always --output none
APP_FQDN=$(az container show -g "$RESOURCE_GROUP" -n "$APP_ACI" --query ipAddress.fqdn -o tsv)
for attempt in {1..36}; do
 if curl -fsS "http://${APP_FQDN}:8080/actuator/health"; then
  echo; echo "Aplicacao: http://${APP_FQDN}:8080"; exit 0
 fi
 sleep 10
done
echo 'Aplicacao nao ficou saudavel dentro do prazo.' >&2
exit 1
