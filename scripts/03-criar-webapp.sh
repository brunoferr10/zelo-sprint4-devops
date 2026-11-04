#!/usr/bin/env bash
# Executar na VM, apos az login --use-device-code e selecao da assinatura.
set -euo pipefail
source "$(dirname "$0")/00-config.sh"
az provider register --namespace Microsoft.Web --wait
if ! az group show -n "$APP_RG" -o none 2>/dev/null; then
  az group create -n "$APP_RG" -l "$LOCATION" -o none
fi
az appservice plan create -g "$APP_RG" -n "$APP_PLAN" -l "$LOCATION" --is-linux --sku "$APP_SKU" -o none
az webapp create -g "$APP_RG" -n "$WEB_APP_NAME" --plan "$APP_PLAN" --runtime 'JAVA:21-java21' -o none
az webapp update -g "$APP_RG" -n "$WEB_APP_NAME" --https-only true -o none
az webapp config set -g "$APP_RG" -n "$WEB_APP_NAME" --startup-file 'java -jar /home/site/wwwroot/app.jar' -o none
echo "Web App criado. Configure variaveis secretas no Azure DevOps e execute a pipeline."
az webapp show -g "$APP_RG" -n "$WEB_APP_NAME" --query defaultHostName -o tsv
